// design-to-figma · measure.js · read-only use_figma script (load figma-use first).
// Measures the frames or nodes in NODE_IDS for the critique lenses and the refuter
// (references/critique-lenses.md): text contrast from resolved variables, the text-size floor,
// touch targets, values not bound to a variable or style, and frames that look like detached
// components. It writes nothing. Pass several IDs to measure several frames in one call.
// Replace the two parameter lines below, then run the whole file as the use_figma code.
const NODE_IDS = ["__NODE_IDS__"];
const OPTIONS = { /* __OPTIONS__ */ };

const opts = { textFloor: 11, touch: true, targetMin: 44, maxExamples: 25, ...OPTIONS };
const INTERACTIVE = /button|btn|input|field|checkbox|radio|switch|toggle|tab|link|chip|select|dropdown|menu ?item|nav/i;
const SPACING_FIELDS = ['itemSpacing', 'counterAxisSpacing', 'paddingLeft', 'paddingRight', 'paddingTop', 'paddingBottom'];
const RADIUS_FIELDS = ['cornerRadius', 'topLeftRadius', 'topRightRadius', 'bottomLeftRadius', 'bottomRightRadius'];

const out = {
  measured: [], notFound: [],
  contrast: { checked: 0, failures: [], unmeasured: [] },
  textFloor: { floor: opts.textFloor, failures: [] },
  targets: opts.touch ? { min: opts.targetMin, failures: [] } : null,
  unbound: { fills: { count: 0, examples: [] }, strokes: { count: 0, examples: [] }, spacing: { count: 0, examples: [] }, radius: { count: 0, examples: [] }, text: { count: 0, examples: [] } },
  detachedCandidates: [],
  limits: 'Backgrounds come from ancestor fills only (a shape drawn behind the text by a sibling is not seen); text with no opaque ancestor is measured over white.',
};
const push = (list, item) => { if (list.length < opts.maxExamples) list.push(item); };
const addUnbound = (kind, item) => { out.unbound[kind].count++; push(out.unbound[kind].examples, item); };

const toHex = ({ r, g, b }) => '#' + [r, g, b].map((c) => Math.round(c * 255).toString(16).padStart(2, '0')).join('').toUpperCase();
const lum = ({ r, g, b }) => {
  const ch = (c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
  return 0.2126 * ch(r) + 0.7152 * ch(g) + 0.0722 * ch(b);
};
const over = (top, a, base) => ({ r: top.r * a + base.r * (1 - a), g: top.g * a + base.g * (1 - a), b: top.b * a + base.b * (1 - a) });
const isMixed = (v) => v === figma.mixed || typeof v === 'symbol';

// The top visible paint of a node, as { kind, color, alpha, variable } for a solid paint.
async function topPaint(node) {
  if (!node || isMixed(node.fills) || !Array.isArray(node.fills)) return null;
  const visible = node.fills.filter((p) => p.visible !== false);
  if (!visible.length) return null;
  const p = visible[visible.length - 1];
  if (p.type !== 'SOLID') return { kind: 'other' };
  let color = { ...p.color, a: 1 }; let variable = null;
  const alias = p.boundVariables && p.boundVariables.color;
  if (alias) {
    const v = await figma.variables.getVariableByIdAsync(alias.id);
    if (v) { const res = v.resolveForConsumer(node); if (res && res.value && typeof res.value === 'object') color = { a: 1, ...res.value }; variable = v.name; }
  }
  return { kind: 'solid', color, alpha: (color.a ?? 1) * (p.opacity ?? 1), variable };
}

async function measureContrast(text, sizes) {
  if (isMixed(text.fills)) { push(out.contrast.unmeasured, { nodeId: text.id, name: text.name, reason: 'mixed fills' }); return; }
  const fg = await topPaint(text);
  if (!fg || fg.kind !== 'solid') { push(out.contrast.unmeasured, { nodeId: text.id, name: text.name, reason: 'no solid text fill' }); return; }
  const layers = []; let bgVariable = null;
  for (let n = text.parent; n; n = n.parent) {
    const p = await topPaint(n);
    if (!p) continue;
    if (p.kind !== 'solid') { push(out.contrast.unmeasured, { nodeId: text.id, name: text.name, reason: `background on ${n.name} is not a solid color` }); return; }
    if (bgVariable === null) bgVariable = p.variable;
    layers.push(p);
    if (p.alpha >= 1) break;
  }
  let bg = { r: 1, g: 1, b: 1 };
  for (let i = layers.length - 1; i >= 0; i--) bg = over(layers[i].color, layers[i].alpha, bg);
  const fgc = over(fg.color, fg.alpha * (text.opacity ?? 1), bg);
  const [hi, lo] = [lum(fgc), lum(bg)].sort((a, b) => b - a);
  const ratio = Math.round(((hi + 0.05) / (lo + 0.05)) * 100) / 100;
  const size = Math.min(...sizes);
  const style = String((text.fontName && text.fontName.style) || '');
  const bold = typeof text.fontWeight === 'number' ? text.fontWeight >= 700 : /bold|black|heavy/i.test(style) && !/semi\s?bold|demi/i.test(style);
  const required = size >= 24 || (size >= 18.66 && bold) ? 3 : 4.5;
  out.contrast.checked++;
  if (ratio < required) push(out.contrast.failures, { nodeId: text.id, name: text.name, text: String(text.characters || '').slice(0, 40), fontSize: size, fg: toHex(fgc), bg: toHex(bg), fgVariable: fg.variable, bgVariable, ratio, required });
}

function fontSizes(text) {
  if (!isMixed(text.fontSize)) return [text.fontSize];
  return text.getStyledTextSegments(['fontSize']).map((s) => s.fontSize);
}

function checkUnbound(node) {
  const bv = node.boundVariables || {};
  for (const [kind, styleField] of [['fills', 'fillStyleId'], ['strokes', 'strokeStyleId']]) {
    const paints = node[kind];
    if (!Array.isArray(paints) || (node[styleField] && !isMixed(node[styleField]))) continue;
    const loose = paints.find((p) => p.visible !== false && p.type === 'SOLID' && !(p.boundVariables && p.boundVariables.color));
    if (loose) addUnbound(kind, { nodeId: node.id, name: node.name, value: toHex(loose.color) });
  }
  if (node.layoutMode && node.layoutMode !== 'NONE') {
    for (const f of SPACING_FIELDS) if (typeof node[f] === 'number' && node[f] > 0 && !bv[f]) addUnbound('spacing', { nodeId: node.id, name: node.name, field: f, value: node[f] });
  }
  const radii = isMixed(node.cornerRadius) ? RADIUS_FIELDS.slice(1) : ['cornerRadius'];
  for (const f of radii) {
    const bound = bv[f] || (f === 'cornerRadius' && RADIUS_FIELDS.slice(1).every((c) => bv[c]));
    if (typeof node[f] === 'number' && node[f] > 0 && !bound) { addUnbound('radius', { nodeId: node.id, name: node.name, field: f, value: node[f] }); break; }
  }
  if (node.type === 'TEXT' && !node.textStyleId && !bv.fontSize) addUnbound('text', { nodeId: node.id, name: node.name, text: String(node.characters || '').slice(0, 40) });
}

async function checkTarget(node) {
  let label = node.name;
  if (node.type === 'INSTANCE') { const main = await node.getMainComponentAsync(); if (main) label += ' ' + main.name + (main.parent ? ' ' + main.parent.name : ''); }
  const interactive = INTERACTIVE.test(label) || (Array.isArray(node.reactions) && node.reactions.length > 0);
  const box = node.absoluteBoundingBox;
  if (interactive && box && (box.width < opts.targetMin || box.height < opts.targetMin)) push(out.targets.failures, { nodeId: node.id, name: node.name, width: Math.round(box.width), height: Math.round(box.height), min: opts.targetMin });
}

async function walk(node, inInstance) {
  if (node.visible === false) return;
  if (node.type === 'TEXT') {
    const sizes = fontSizes(node);
    await measureContrast(node, sizes);
    const min = Math.min(...sizes);
    if (min < opts.textFloor) push(out.textFloor.failures, { nodeId: node.id, name: node.name, text: String(node.characters || '').slice(0, 40), fontSize: min, floor: opts.textFloor });
  }
  if (opts.touch && (node.type === 'INSTANCE' || (Array.isArray(node.reactions) && node.reactions.length))) await checkTarget(node);
  const insideInstance = inInstance || node.type === 'INSTANCE';
  if (!insideInstance) {
    checkUnbound(node);
    if ((node.type === 'FRAME' || node.type === 'GROUP') && node.name.includes('/')) push(out.detachedCandidates, { nodeId: node.id, name: node.name });
  }
  for (const child of node.children || []) await walk(child, insideInstance);
}

for (const id of NODE_IDS) {
  const node = await figma.getNodeByIdAsync(id);
  if (!node) { out.notFound.push(id); continue; }
  out.measured.push({ nodeId: node.id, name: node.name });
  await walk(node, false);
}
return out;
