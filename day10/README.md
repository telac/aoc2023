# google sheets commands

Format the data:

```
=REGEXEXTRACT(TO_TEXT(Sheet1!A1); REPT("(.)"; LEN(Sheet1!A1)))
```

Get the max from the grid:

```
=MAX(2:1000)
```

Get midpoint, and round it:

```
=ROUND(A1/2, 0)
```

Route visualized in sheets

![Route](route.png)
