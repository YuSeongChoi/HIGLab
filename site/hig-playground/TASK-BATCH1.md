# Batch 1: New HIG Playground Component Pages

## Reference Template
Use `components/buttons.html` as the template. Each page follows the same structure:
- Header with nav
- Breadcrumb
- Page title + description
- playground-layout grid: iPhone frame (left) + right panel (controls + guidelines + code preview)
- Interactive controls that update the iPhone preview in real-time
- SwiftUI code preview that updates with the controls
- Do/Don't guidelines section (static text for now)

## Components to Create

### Content Category (4 pages)
1. **charts.html** — Charts (SwiftUI Charts framework)
   - Bar, Line, Area, Pie chart types
   - Controls: chart type, data points, color scheme, show legend toggle
   - Do: Use clear labels, appropriate chart type for data
   - Don't: Overcrowd with data, use 3D effects, misleading scales

2. **image-views.html** — Image Views
   - resizable(), aspectRatio, contentMode (.fit, .fill), clipShape
   - Controls: content mode, corner radius, overlay toggle, shadow
   - Do: Maintain aspect ratio, use appropriate resolution
   - Don't: Stretch images, use low-res on retina displays

3. **text-views.html** — Text Views (read-only styled text)
   - Font styles (title, body, caption, etc.), line limit, truncation
   - Controls: font style, weight, alignment, line limit, color
   - Do: Use Dynamic Type, semantic font styles
   - Don't: Use fixed font sizes, ignore accessibility

4. **web-views.html** — Web Views
   - WKWebView container with URL bar
   - Controls: show/hide nav bar, progress indicator, allow zoom
   - Do: Show loading state, handle errors gracefully
   - Don't: Replace native UI with web content unnecessarily

### Layout Category (6 pages)
5. **collections.html** — Collections (LazyVGrid/LazyHGrid)
   - Grid of items with different column counts
   - Controls: columns (2/3/4), spacing, item shape (square/rounded)
   - Do: Consistent item sizes, appropriate spacing
   - Don't: Mix wildly different item sizes, tiny tap targets

6. **disclosure-groups.html** — Disclosure Groups
   - Expandable/collapsible sections
   - Controls: default expanded, animation, nested levels
   - Do: Clear hierarchy, meaningful labels
   - Don't: Deep nesting (>3 levels), hide critical info

7. **labels.html** — Labels (icon + text)
   - SF Symbol + text combinations, label styles
   - Controls: icon position, style (.titleOnly, .iconOnly, .titleAndIcon), size
   - Do: Pair icon with text for clarity, use SF Symbols
   - Don't: Use ambiguous icons alone, mismatched icons

8. **outline-views.html** — Outline Views
   - Hierarchical tree list with expand/collapse
   - Controls: indent level, show disclosure indicator, selection style
   - Do: Clear parent-child relationships
   - Don't: Flatten deep hierarchies

9. **split-views.html** — Split Views (NavigationSplitView)
   - Sidebar + detail layout
   - Controls: column visibility, sidebar width, style (prominent/balanced)
   - Do: Maintain context in sidebar, adaptive layout
   - Don't: Force split view on compact screens

10. **tables.html** — Tables
    - Multi-column sortable table
    - Controls: column count, sortable toggle, row selection, alternating rows
    - Do: Align data appropriately, allow sorting
    - Don't: Cramped columns, no scroll for overflow

### Selection & Status (5 pages)
11. **color-wells.html** — Color Wells (ColorPicker)
    - Color picker circle that opens picker sheet
    - Controls: supports opacity, style (wheel/grid/spectrum)
    - Do: Show current color clearly, provide presets
    - Don't: Tiny tap target, no color preview

12. **pickers.html** — Pickers (wheel, menu, inline styles)
    - Item selection with different display styles
    - Controls: style (wheel/menu/segmented/inline), items count
    - Do: Reasonable number of options, clear labels
    - Don't: Too many items in wheel, vague labels

13. **steppers.html** — Steppers
    - +/- increment control with value display
    - Controls: step size, range, label position
    - Do: Show current value, appropriate range
    - Don't: No value display, unreasonable step sizes

14. **activity-rings.html** — Activity Rings
    - Concentric progress rings (like Apple Watch)
    - Controls: ring count, progress values, colors, animation
    - Do: Clear progress indication, meaningful colors
    - Don't: Too many rings, unclear what they represent

15. **gauges.html** — Gauges
    - Circular/linear gauge indicators
    - Controls: style (circular/linear), range, current value, color gradient
    - Do: Clear min/max labels, appropriate scale
    - Don't: Misleading scale, no context for values

## Style Guidelines
- Use iOS system colors (--ios-blue, --ios-green, etc.)
- iPhone frame: 375x812px with Dynamic Island
- All interactive — controls on right panel update iPhone preview live
- Include SwiftUI code preview that updates with controls
- Korean descriptions for page-desc, English for screen content inside iPhone
- Responsive: single column on mobile (<860px)

## File naming
All lowercase with hyphens: `charts.html`, `image-views.html`, etc.
Place in `components/` directory.
