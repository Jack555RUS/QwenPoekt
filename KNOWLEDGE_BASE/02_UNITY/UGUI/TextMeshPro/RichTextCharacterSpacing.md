---
status: stable
created: 2026-02-28
last_reviewed: 2026-02-28
source: Unity Package Documentation
tags: unity, package, documentation
---
# Character Spacing

The `<cspace>` tag allows you to adjust character spacing, either absolute or relative to the original font Asset. You can use pixels or font units.

Postive adjustments push the characters apart, negative adjustments pull them together.

The closing `</cspace>` tag reverts back to the font's normal spacing.

**Example:**

```
<cspace=1em>Spacing</cspace> is just as important as <cspace=-0.5em>timing.
```

![Example image](../images/TMP_RichTextSpacing.png)<br/>
_Character spacing_
