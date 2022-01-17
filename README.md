# cumcord theme settings parser

Parses cumcord theme settings.

```css
/* THE FOLLOWING EXAMPLE SUBJECT TO CHANGE UNTIL STANDARDISED */

/* TODO: once we solidify how were doing imports, put here */

/* cc:settings */
:root {
  --main-color: red; /* cc:dropdown: #123123, #123765, #123865 */
  --another-var: blue; /* cc:colorpicker */
}
/* cc:settings */
.theme-dark {
    --watermark-override: "Cumcord is cool, enjoy my theme"; /* cc:text */
}
```

## common terminology in code

Idk what the parts of a CSS file should technically be called,
so here's what I'm going with.

| term | meaning |
|-|-|
| Selector | selects elements to apply the following block to |
| Block | the part enclosed in `{}` after a selector |
| Property | an individual style insidea block - for example setting a colour or margin |
| Rule | this term is banned for being too ambiguous :p |
| Stack | a working list of characters. Technically not a stack but treated mostly like one. |