---
figma_url: <https://www.figma.com/design/FILE_KEY/NAME>
figma_file_key: <FILE_KEY>
last_sync: <ISO 8601 timestamp, e.g. 2026-01-31T12:00:00Z>
scope: <full | minimal>
colors:
  <role-slug>: "<value>"
typography:
  <role-slug>:
    fontFamily: "<family>"
    fontSize: "<size>"
    fontWeight: <weight>
    lineHeight: "<value>"
rounded:
  sm: "<value>"
  md: "<value>"
spacing:
  <step>: "<value>"
components:
  <component-slug>:
    backgroundColor: "{colors.<role-slug>}"
    textColor: "{colors.<role-slug>}"
    rounded: "{rounded.md}"
---

# Design System: <Project title>

## Overview

<Creative direction and personality in two or three sentences.>

## Colors

<Roles and how they are used. Values live in the frontmatter above and in Figma variables.>

## Typography

<Families, scale and usage.>

## Layout

<Spacing scale, grid, density.>

## Elevation & Depth

<Shadows and layers, if any.>

## Shapes

<Radius vocabulary.>

## Components

<List of components and their variants and states, matching the Figma Components page.>

## Do's and Don'ts

- Do: <rule>
- Don't: <rule>

## Sync snapshot

Compact record used to detect manual Figma edits (see references/sync-rules.md). Sorted alphabetically; no node IDs. Move to `DESIGN.sync.json` when it exceeds 150 lines.

```yaml
lastSync: <ISO 8601 timestamp>
pages:
  <page name>: [<top-level frame>, <top-level frame>]
variables:
  <collection>:
    <variable name>: { <mode>: <value>, <mode>: <value> }
styles: [<style name>]
components: [<component or set name>]
```
