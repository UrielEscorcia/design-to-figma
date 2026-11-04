// Tests for the read-only use_figma scripts in skills/design-to-figma/assets/scripts/.
// The scripts are plain use_figma code (top-level await and return). Each test runs one against a
// small fake `figma` API built from the Plugin API types, so the measurements are checked without
// a Figma file or any MCP call. Run: node tests/figma-scripts.test.mjs
import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const dir = new URL('../skills/design-to-figma/assets/scripts/', import.meta.url);
const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;

function run(file, figma, replacements) {
  let code = readFileSync(new URL(file, dir), 'utf8');
  for (const [from, to] of Object.entries(replacements)) {
    assert.ok(code.includes(from), `${file} must contain the placeholder ${from}`);
    code = code.replace(from, to);
  }
  return new AsyncFunction('figma', code)(figma);
}

const hex = (h, a = 1) => ({ r: parseInt(h.slice(1, 3), 16) / 255, g: parseInt(h.slice(3, 5), 16) / 255, b: parseInt(h.slice(5, 7), 16) / 255, a });
const solid = (h, extra = {}) => ({ type: 'SOLID', visible: true, opacity: 1, color: (({ r, g, b }) => ({ r, g, b }))(hex(h)), ...extra });

// A variable resolves per consumer: `byConsumer` maps a node id (or '*') to a color hex.
function colorVar(id, name, byConsumer) {
  return {
    id, name, resolvedType: 'COLOR',
    resolveForConsumer(node) {
      let n = node;
      while (n) { if (byConsumer[n.id]) return { value: hex(byConsumer[n.id]), resolvedType: 'COLOR' }; n = n.parent; }
      return { value: hex(byConsumer['*']), resolvedType: 'COLOR' };
    },
  };
}

function makeFigma(roots, variables = []) {
  const mixed = Symbol('mixed');
  const byId = new Map();
  const index = (node, parent) => {
    node.parent = parent; node.visible = node.visible ?? true; node.opacity = node.opacity ?? 1;
    node.fills = node.fills ?? []; node.strokes = node.strokes ?? []; node.boundVariables = node.boundVariables ?? {};
    node.children = node.children ?? (['FRAME', 'INSTANCE', 'COMPONENT', 'GROUP', 'PAGE'].includes(node.type) ? [] : undefined);
    if (node.type === 'TEXT') node.textStyleId = node.textStyleId ?? '';
    byId.set(node.id, node);
    for (const c of node.children ?? []) index(c, node);
    if (node.type === 'INSTANCE') node.getMainComponentAsync = async () => ({ name: node.mainName ?? node.name, parent: null });
    if (node.type === 'TEXT') node.getStyledTextSegments = (fields) => node.segments ?? [{ fontSize: node.fontSize, start: 0, end: (node.characters ?? '').length }];
  };
  for (const r of roots) index(r, null);
  const vars = new Map(variables.map((v) => [v.id, v]));
  return {
    mixed,
    getNodeByIdAsync: async (id) => byId.get(id) ?? null,
    variables: { getVariableByIdAsync: async (id) => vars.get(id) ?? null },
  };
}

const tests = [];
const test = (name, fn) => tests.push([name, fn]);

// ---------- measure.js ----------
const measure = (figma, ids, options = '{}') => run('measure.js', figma, {
  '["__NODE_IDS__"]': JSON.stringify(ids),
  '{ /* __OPTIONS__ */ }': options,
});

test('contrast resolves bound variables per consumer and reports the failing pair', async () => {
  const card = { id: '1:1', name: 'Card', type: 'FRAME', fills: [solid('#FFFFFF', { boundVariables: { color: { type: 'VARIABLE_ALIAS', id: 'v-surface' } } })],
    children: [{ id: '1:2', name: 'RFC', type: 'TEXT', characters: 'XAXX010101000', fontSize: 12, fontName: { family: 'Geist Mono', style: 'Regular' },
      fills: [solid('#000000', { boundVariables: { color: { type: 'VARIABLE_ALIAS', id: 'v-tertiary' } } })] }] };
  const figma = makeFigma([card], [colorVar('v-surface', 'bg/surface', { '*': '#FFFFFF' }), colorVar('v-tertiary', 'text/tertiary', { '*': '#8F959B' })]);
  const out = await measure(figma, ['1:1']);
  assert.equal(out.contrast.checked, 1);
  assert.equal(out.contrast.failures.length, 1);
  const f = out.contrast.failures[0];
  assert.equal(f.nodeId, '1:2');
  assert.equal(f.fg, '#8F959B'); assert.equal(f.bg, '#FFFFFF');
  assert.equal(f.fgVariable, 'text/tertiary'); assert.equal(f.bgVariable, 'bg/surface');
  assert.equal(f.required, 4.5);
  assert.ok(f.ratio > 2.9 && f.ratio < 3.1, `ratio ${f.ratio}`);
});

test('contrast uses the mode the node resolves to, so a passing dark-mode value passes', async () => {
  const card = { id: '2:1', name: 'Card', type: 'FRAME', fills: [solid('#000000', { boundVariables: { color: { type: 'VARIABLE_ALIAS', id: 'v-bg' } } })],
    children: [{ id: '2:2', name: 'Label', type: 'TEXT', characters: 'Hola', fontSize: 14, fontName: { family: 'Geist', style: 'Regular' },
      fills: [solid('#000000', { boundVariables: { color: { type: 'VARIABLE_ALIAS', id: 'v-fg' } } })] }] };
  const figma = makeFigma([card], [colorVar('v-bg', 'bg/canvas', { '*': '#0F1116' }), colorVar('v-fg', 'text/primary', { '*': '#F4F6F9' })]);
  const out = await measure(figma, ['2:1']);
  assert.equal(out.contrast.checked, 1);
  assert.deepEqual(out.contrast.failures, []);
});

test('large text uses 3:1, and translucent text is composited over its background', async () => {
  const frame = { id: '3:1', name: 'Hero', type: 'FRAME', fills: [solid('#FFFFFF')], children: [
    { id: '3:2', name: 'Big', type: 'TEXT', characters: '$184,320', fontSize: 32, fontName: { family: 'Geist', style: 'Bold' }, fills: [solid('#8A8F96')] },
    { id: '3:3', name: 'Faded', type: 'TEXT', characters: 'nota', fontSize: 14, fontName: { family: 'Geist', style: 'Regular' }, fills: [solid('#000000', { opacity: 0.4 })] },
    { id: '3:4', name: 'Large regular', type: 'TEXT', characters: 'Saldo', fontSize: 24, fontName: { family: 'Geist', style: 'Regular' }, fills: [solid('#8A8F96')] },
    { id: '3:5', name: 'Small regular', type: 'TEXT', characters: 'Saldo', fontSize: 20, fontName: { family: 'Geist', style: 'Regular' }, fills: [solid('#8A8F96')] },
    { id: '3:6', name: 'Semibold', type: 'TEXT', characters: 'Saldo', fontSize: 20, fontName: { family: 'Geist', style: 'SemiBold' }, fills: [solid('#8A8F96')] },
  ] };
  const out = await measure(makeFigma([frame]), ['3:1']);
  const ids = out.contrast.failures.map((f) => f.nodeId);
  assert.ok(!ids.includes('3:2'), 'large text at ~3.3:1 passes the 3:1 rule');
  assert.ok(ids.includes('3:3'), 'black at 40% over white is ~#999999 and fails 4.5:1');
  assert.ok(!ids.includes('3:4'), '24 px regular is large text: 3:1');
  assert.ok(ids.includes('3:5'), '20 px regular is not large text: 4.5:1');
  assert.ok(ids.includes('3:6'), 'SemiBold is not bold for WCAG, so 20 px SemiBold needs 4.5:1');
  assert.equal(out.contrast.failures.find((f) => f.nodeId === '3:3').fg, '#999999');
});

test('a background the script cannot read (image or gradient) is reported as unmeasured, not as a pass', async () => {
  const frame = { id: '4:1', name: 'Banner', type: 'FRAME', fills: [{ type: 'IMAGE', visible: true, opacity: 1 }], children: [
    { id: '4:2', name: 'Title', type: 'TEXT', characters: 'Hola', fontSize: 14, fontName: { family: 'Geist', style: 'Regular' }, fills: [solid('#FFFFFF')] }] };
  const out = await measure(makeFigma([frame]), ['4:1']);
  assert.equal(out.contrast.checked, 0);
  assert.deepEqual(out.contrast.unmeasured.map((u) => u.nodeId), ['4:2']);
});

test('the text floor flags the smallest segment of mixed-size text', async () => {
  const frame = { id: '5:1', name: 'Row', type: 'FRAME', fills: [solid('#FFFFFF')], children: [
    { id: '5:2', name: 'Meta', type: 'TEXT', characters: 'A-0148 · 12 sep', fontSize: Symbol.for('mixed'), fontName: { family: 'Geist', style: 'Regular' }, fills: [solid('#111111')],
      segments: [{ fontSize: 13, start: 0, end: 6 }, { fontSize: 10, start: 6, end: 15 }] },
    { id: '5:3', name: 'Ok', type: 'TEXT', characters: 'Total', fontSize: 14, fontName: { family: 'Geist', style: 'Regular' }, fills: [solid('#111111')] },
  ] };
  const figma = makeFigma([frame]);
  frame.children[0].fontSize = figma.mixed;
  const out = await measure(figma, ['5:1'], '{ textFloor: 11 }');
  assert.deepEqual(out.textFloor.failures.map((f) => [f.nodeId, f.fontSize]), [['5:2', 10]]);
});

test('unbound values are listed; bound ones and instance internals are not', async () => {
  const frame = { id: '6:1', name: 'Screen', type: 'FRAME', layoutMode: 'VERTICAL', itemSpacing: 16, paddingLeft: 24, paddingRight: 24, paddingTop: 0, paddingBottom: 0,
    boundVariables: { paddingLeft: { type: 'VARIABLE_ALIAS', id: 'v-s' }, paddingRight: { type: 'VARIABLE_ALIAS', id: 'v-s' } },
    cornerRadius: 20, fills: [solid('#F4F6F9')], children: [
      { id: '6:2', name: 'Loose', type: 'TEXT', characters: 'x', fontSize: 14, fontName: { family: 'Geist', style: 'Regular' }, fills: [solid('#111111')] },
      { id: '6:3', name: 'Button', type: 'INSTANCE', fills: [solid('#076FB8')], cornerRadius: 12, children: [
        { id: '6:4', name: 'Label', type: 'TEXT', characters: 'Crear', fontSize: 14, fontName: { family: 'Geist', style: 'Medium' }, fills: [solid('#FFFFFF')] }] },
    ] };
  const out = await measure(makeFigma([frame]), ['6:1']);
  assert.deepEqual(out.unbound.fills.examples.map((e) => e.nodeId).sort(), ['6:1', '6:2']);
  assert.deepEqual(out.unbound.spacing.examples.map((e) => `${e.nodeId}:${e.field}`), ['6:1:itemSpacing']);
  assert.deepEqual(out.unbound.radius.examples.map((e) => e.nodeId), ['6:1']);
  assert.deepEqual(out.unbound.text.examples.map((e) => e.nodeId), ['6:2']);
});

test('touch targets below the minimum are flagged on interactive instances only', async () => {
  const frame = { id: '7:1', name: 'Bar', type: 'FRAME', fills: [solid('#FFFFFF')], children: [
    { id: '7:2', name: 'Icon button', type: 'INSTANCE', mainName: 'IconButton', absoluteBoundingBox: { x: 0, y: 0, width: 32, height: 32 } },
    { id: '7:3', name: 'Button', type: 'INSTANCE', mainName: 'Button', absoluteBoundingBox: { x: 0, y: 0, width: 120, height: 44 } },
    { id: '7:4', name: 'Avatar', type: 'INSTANCE', mainName: 'Avatar', absoluteBoundingBox: { x: 0, y: 0, width: 24, height: 24 } },
  ] };
  const out = await measure(makeFigma([frame]), ['7:1'], '{ touch: true, targetMin: 44 }');
  assert.deepEqual(out.targets.failures.map((f) => f.nodeId), ['7:2']);
  const off = await measure(makeFigma([frame]), ['7:1'], '{ touch: false }');
  assert.equal(off.targets, null);
});

test('frames named like components are detached candidates; unknown ids are reported', async () => {
  const frame = { id: '8:1', name: 'Screen', type: 'FRAME', fills: [solid('#FFFFFF')], children: [
    { id: '8:2', name: 'Card/KPI', type: 'FRAME', fills: [solid('#FFFFFF')] }] };
  const out = await measure(makeFigma([frame]), ['8:1', '9:9']);
  assert.deepEqual(out.detachedCandidates.map((d) => d.nodeId), ['8:2']);
  assert.deepEqual(out.notFound, ['9:9']);
  assert.deepEqual(out.measured, [{ nodeId: '8:1', name: 'Screen' }]);
});

test('the example cap is per frame, totals stay exact, and a cut list is flagged, never read as complete', async () => {
  const rows = (prefix, n) => Array.from({ length: n }, (_, i) => ({ id: `${prefix}:${i + 10}`, name: `Row ${i}`, type: 'TEXT', characters: 'RFC', fontSize: 12,
    fontName: { family: 'Geist', style: 'Regular' }, fills: [solid('#8F959B')] }));
  const a = { id: 'A:1', name: 'List · 1440', type: 'FRAME', fills: [solid('#FFFFFF')], children: rows('A', 30) };
  const b = { id: 'B:1', name: 'List · 390', type: 'FRAME', fills: [solid('#FFFFFF')], children: rows('B', 2) };
  const out = await measure(makeFigma([a, b]), ['A:1', 'B:1'], '{ maxExamples: 25 }');
  assert.equal(out.counts.contrastFailures, 32, 'the total counts every failure');
  const inB = out.contrast.failures.filter((f) => f.frameId === 'B:1');
  assert.equal(inB.length, 2, 'a later frame keeps its own failures');
  assert.equal(out.contrast.failures.filter((f) => f.frameId === 'A:1').length, 25);
  assert.deepEqual(out.truncated.find((t) => t.list === 'contrast.failures'), { frameId: 'A:1', list: 'contrast.failures', shown: 25, total: 30 });
  assert.ok(out.truncated.every((t) => t.frameId === 'A:1'), 'frame B, with 2 rows, is never cut');
  assert.equal(out.unbound.text.count, 32, 'unbound totals stay exact too');
});

// ---------- snapshot.js ----------
test('snapshot lists pages, frames, components, styles and variable values per mode, sorted', async () => {
  const pages = [
    { id: 'p2', name: '📱 Screens', type: 'PAGE', children: [{ id: 's2', name: 'Inicio · 390', type: 'FRAME' }, { id: 's1', name: 'Inicio · 1440', type: 'FRAME' }] },
    { id: 'p1', name: '🧩 Components', type: 'PAGE', children: [
      { id: 'c2', name: 'Status/Factura', type: 'COMPONENT_SET', children: [{ id: 'c3', name: 'state=paid', type: 'COMPONENT' }] },
      { id: 'c1', name: 'Button', type: 'COMPONENT' }] },
  ];
  for (const p of pages) { p.loadAsync = async () => { p.loaded = true; };
    p.findAllWithCriteria = ({ types }) => { const out = []; const walk = (n) => { for (const c of n.children ?? []) { if (types.includes(c.type)) out.push(c); walk(c); } }; walk(p); return out; }; }
  const collection = { id: 'col', name: 'Semantic', modes: [{ modeId: 'm1', name: 'Light' }, { modeId: 'm2', name: 'Dark' }], variableIds: ['v2', 'v1'] };
  const variables = {
    v1: { id: 'v1', name: 'bg/canvas', resolvedType: 'COLOR', valuesByMode: { m1: hex('#F4F6F9'), m2: hex('#0F1116') } },
    v2: { id: 'v2', name: 'action/primary', resolvedType: 'COLOR', valuesByMode: { m1: { type: 'VARIABLE_ALIAS', id: 'v3' }, m2: hex('#3A93D6', 0.5) } },
    v3: { id: 'v3', name: 'blue/600', resolvedType: 'COLOR', valuesByMode: {} },
  };
  const figma = {
    root: { children: pages },
    getLocalTextStylesAsync: async () => [{ name: 'Body/M' }, { name: 'Amount/Hero' }],
    getLocalEffectStylesAsync: async () => [{ name: 'Shadow/Card' }],
    variables: { getLocalVariableCollectionsAsync: async () => [collection], getVariableByIdAsync: async (id) => variables[id] ?? null },
  };
  const out = await run('snapshot.js', figma, {});
  assert.deepEqual(out.pages, [
    { name: '📱 Screens', frames: ['Inicio · 1440', 'Inicio · 390'] },
    { name: '🧩 Components', frames: ['Button', 'Status/Factura'] },
  ].sort((a, b) => a.name.localeCompare(b.name)));
  assert.deepEqual(out.components, ['Button', 'Status/Factura']);
  assert.deepEqual(out.styles, { text: ['Amount/Hero', 'Body/M'], effect: ['Shadow/Card'] });
  assert.deepEqual(Object.keys(out.variables.Semantic), ['action/primary', 'bg/canvas']);
  assert.deepEqual(out.variables.Semantic['bg/canvas'], { Light: '#F4F6F9', Dark: '#0F1116' });
  assert.deepEqual(out.variables.Semantic['action/primary'], { Light: '{blue/600}', Dark: '#3A93D680' });
  assert.ok(pages.every((p) => p.loaded), 'every page is loaded before it is read');
});

let failed = 0;
for (const [name, fn] of tests) {
  try { await fn(); console.log(`ok   ${name}`); }
  catch (e) { failed++; console.log(`FAIL ${name}\n     ${e.message.split('\n')[0]}`); }
}
process.exit(failed ? 1 : 0);
