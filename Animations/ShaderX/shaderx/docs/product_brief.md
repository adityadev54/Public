# ShaderX product brief draft

ShaderX is a daily creative product built around theme-derived shader components and four master tools that combine them. The product needs a coherent way to discover ingredients, compose them, and return to work. Its interface should inherit Gita’s interaction structure while establishing a separate brand.

## Confirmed direction

- Theme components guide the shader library. The user’s galaxy → spiral galaxy example explains a method for choosing a specific subject within a broader theme; it does not select the first effect to implement.
- The library should develop an original visual vocabulary rather than repeat the familiar shader catalog.
- Four master tools will blend shaders. Their names, responsibilities, and interaction models are still to be defined or supplied by the user.
- Use Kin UI and the relevant tools already used in Gita. Preserve Gita’s layout structure while allowing differences required by shader creation.
- The experience should feel premium and be useful daily.
- ShaderX needs a distinctive brand color outside blue, teal, and similar hues. No specific color is approved.

## Working product model

A **theme** supplies context for discovery. A **component** is a specific visual ingredient drawn from that theme. A **composition** is the editable result created with selected ingredients and the master tools. A **saved composition** preserves the recipe so it can be reopened and changed.

These distinctions are a proposal grounded in the brief. They keep catalog organization separate from rendering and from the user’s work. The component’s exact granularity remains open: a component might be an independently rendered subject, or a smaller building block used within another effect. The implementation must not force that choice prematurely.

Originality comes from selecting subjects thoughtfully and designing their visual behavior. A theme name, an unfamiliar label, or a changed palette alone does not establish an original effect. A candidate should have a recognizable subject, a reason to exist in the catalog, and a useful relationship to other components.

## Proposed daily journey

1. Return to an unfinished composition or browse themes and their components.
2. Inspect a component’s appearance and behavior before adding it to the workspace.
3. Work with the four master tools while seeing their effect on the composition.
4. Save, reopen, and make variations without losing the starting recipe.
5. Use the result in the destination the product is designed for.

The primary output is unresolved: effects for applications or websites, personal animated visuals or wallpapers, or both. This decision changes the editor, export requirements, and platform priorities. Export format, cloud accounts, sharing, and publishing are not established requirements.

## Four master tools

The earlier Form / Motion / Light / Blend labels are discarded as product decisions. Four sliders are not evidence of four master tools. A tool could be a workspace operation with several controls; its meaning should come from the intended creative process.

Before implementation, define each tool’s purpose, what it accepts, how it changes the composition, how it works with the other three tools, how a user reverses its effects, and what must be saved to reproduce the result. This definition should determine the UI and rendering contract.

Whether tools support cross-theme combinations, ordered operations, masks, spatial mixing, or other blending behavior is open. Linear crossfade between two shader colors is only one possible technique and does not define the product.

## Proposed information architecture

| Area | Purpose | Relationship to the brief |
| --- | --- | --- |
| Home | Resume work and find a useful starting point | Proposed daily entry point |
| Themes and components | Explore the visual vocabulary | Derived from the theme-component idea |
| Workspace | Compose using the four master tools | Derived from the creation intent |
| Library | Reopen and vary saved work | Proposed support for daily use |
| Settings | Appearance, accessibility, and eventual quality preferences | Shared app foundation |

These areas need not become five navigation tabs. Gita’s drawer and focused content routes provide a better starting point for deciding how they connect.

## Design direction to establish

Preserve Gita’s one-handed reach, content-first hierarchy, bounded reading widths, consistent touch targets, compact overlays, and restrained interface motion. Shader motion belongs in the creative content; interface motion should help navigation and control.

Explore brand directions against the actual shader artwork before selecting a color. Keep the interface accent separate from the output palette: a brand color should not make every shader render in that color. The previous ember palette and slogan are unapproved.

## Decisions needed before implementation

- The four master tools and the behavior of each.
- The main audience and destination for completed work.
- The intended granularity of a component and how combinations should behave.
- Primary platforms and whether the creation experience must be equally capable on phones and desktops.

The next useful deliverable is a defined creation flow and screen structure based on these decisions, followed by a small implementation that proves the intended component and tool contracts. The first theme and effect should be chosen through that process.
