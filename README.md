![Top Language](https://img.shields.io/github/languages/top/Iron-Wolf/script)
![GitHub language count](https://img.shields.io/github/languages/count/Iron-Wolf/script?color=blueviolet)

# Table of contents  
- [Description](#description)
- [Markdown Documentation](#markdown-documentation)
- [Writting Conventions](#writting-conventions)

# Description

Contains scripts and notes on various software (games, tools, linux, ...).  
Serves as a back-up and centralization for all my tuning/tweaking needs.


# Markdown Documentation
I don't know where to put this, so here it is.

## Highlighting box
Highlights a text by framing it in an element with an icon.  
Useful for writing a Wiki.  
This was inspired by some cool documentation, like [Spring Boot](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#using.devtools).

> [✅](# "Tips") Tips title  
> Add another way of doing things or give details on how to use.  
> This box can be expanded with several lines.

> [ℹ️](# "Info") Info title  
> Add details or a context to something

> [⚠️](# "Alert") Alert title  
> Warns or prevent potential consequences

> [🔥](# "Caution") Caution title  
> Extra warning to prevent major issues

> [⛔️](# "Forbidden") Forbidden title  
> Indicate that something is impossible or not advised

> [🚧](# "In Progress") In Progress title  
> Indicate that the information needs to be finished or reworked

> [🩹](# "Problem Solving") Problem Solving title  
> Give instruction on how to resolve or troubleshoot an issue

To add this box, you can use this notation :  
```markdown
              current page
add anchor ─────┐  │    ┌──────  tooltip
            > [ℹ️](# "Info")
            > Text here
```


# Writting Conventions

## Command/code synopsis
Convention used to describe command usage or code snippets (inspired by the man-pages).  
Usefull for text friendly manual or usage tips in documentations.  
- boldface is used for as-is text
- italics are used to indicate replaceable arguments
- Brackets ([]) surround optional arguments
- "rafters" (<>) surround required arguments (postgres use Braces ({}) for that)
- vertical bars (|) separate choices
- ellipses (...) mean that the preceding element can be repeated

All other symbols, including parentheses, should be taken literally
