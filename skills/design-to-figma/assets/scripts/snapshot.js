// design-to-figma · snapshot.js · read-only use_figma script (load figma-use first).
// Returns the sync snapshot fields of references/sync-rules.md (Snapshot) in one call: every
// page with its top-level frame names, component and component-set names, text and effect style
// names, and every local variable with its value per mode. Lists are sorted and contain no node
// IDs or positions, so two runs on an unchanged file return the same output. It writes nothing.
// Add lastSync yourself when you store it. Run the whole file as the use_figma code.

const sortByName = (a, b) => (a < b ? -1 : a > b ? 1 : 0);
const sorted = (list) => [...list].sort(sortByName);
const hex = (c) => {
  const h = '#' + [c.r, c.g, c.b].map((x) => Math.round(x * 255).toString(16).padStart(2, '0')).join('').toUpperCase();
  return c.a !== undefined && c.a < 1 ? h + Math.round(c.a * 255).toString(16).padStart(2, '0').toUpperCase() : h;
};

async function formatValue(value) {
  if (value && typeof value === 'object' && value.type === 'VARIABLE_ALIAS') {
    const target = await figma.variables.getVariableByIdAsync(value.id);
    return `{${target ? target.name : value.id}}`;
  }
  if (value && typeof value === 'object' && 'r' in value) return hex(value);
  return value;
}

const pages = [];
const components = new Set();
for (const page of figma.root.children) {
  await page.loadAsync();
  pages.push({ name: page.name, frames: sorted(page.children.map((n) => n.name)) });
  const found = page.findAllWithCriteria({ types: ['COMPONENT_SET', 'COMPONENT'] });
  const variants = new Set(found.filter((n) => n.type === 'COMPONENT_SET').flatMap((s) => (s.children || []).map((c) => c.id)));
  for (const n of found) if (!variants.has(n.id)) components.add(n.name);
}
pages.sort((a, b) => sortByName(a.name, b.name));

const variables = {};
for (const collection of await figma.variables.getLocalVariableCollectionsAsync()) {
  const entries = [];
  for (const id of collection.variableIds) {
    const v = await figma.variables.getVariableByIdAsync(id);
    if (!v) continue;
    const byMode = {};
    for (const mode of collection.modes) byMode[mode.name] = await formatValue(v.valuesByMode[mode.modeId]);
    entries.push([v.name, byMode]);
  }
  entries.sort((a, b) => sortByName(a[0], b[0]));
  variables[collection.name] = Object.fromEntries(entries);
}

return {
  pages,
  components: sorted(components),
  styles: {
    text: sorted((await figma.getLocalTextStylesAsync()).map((s) => s.name)),
    effect: sorted((await figma.getLocalEffectStylesAsync()).map((s) => s.name)),
  },
  variables,
};
