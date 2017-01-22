> Before using MarkLite you need to look at the basic syntax of about markdown, if you have already mastered, please ignore this document, if it is not, then start learning it now.

### 1. Title

* Use `#` represents a title, a title using a `#`, subheadings two `##`, and so on, a total of six titles.
* Use `=====` represents high-end title, use `---------` indicates the second heading.

1. Preferably a space between `#` and title. Do not ask me why, sometimes seemingly will not be recognized as a title? I have forgotten why they want to add a space, perhaps capricious.
2. `====` and `----` represents the header, equal to more than two can be expressed.
3. I usually use the title tag in the title when grading, the usefulness of this very clear.

#### Example 1

```
# This is a title
## This is the second title
### This is three title
###### This is a six title
```

# This is a title

## This is the second title

### This is three title

#### Example 2

```
This is a title
========

This is the second title
--------------
```

This is a title
========

This is the second title
--------------


### 2. Reference 

Use `>` is a reference, which is a reference to `>>` and then set a reference layer, and so on.

1. If `>` and `>>` nest, then retreated from `>>` `>` when you want to add a space or must be between`>` as a transition, otherwise it defaults to the next and previous lines It is a reference to the same level. As shown in the example.
2. The reference mark can be used in other tags, such as: an ordered list or unordered list tag code markings.

#### Example
```
> This is a reference
>> This is the second reference
>>> This is a reference to three

> This is a reference
```

> This is a reference
>> This is the second reference
>>> This is a reference to three

> This is a reference


### 1.3 block of code

Use `` represents a code block.

This document explains all use Markdown syntax tag example places are marked using a code block.

```

var canvas = document.getElementById ( "canvas");

var context = canvas.getContext ( "2d");

```


### 1.4 lines of code within the

Use `` represent inline code. Middle part of the text of this page is to use the letters of the alphabet in the line of code marked tags.

Example

```
This is the code for `javascript`
```

This is the code for `javascript`

#### 1.5 Links

Use `[](link)` represents inline link. among them:

* Content `[]` to be added within the link text.
* `Link` for the link.

Example

I think [MarkLite](https://appsto.re/cn/jK8Cbb.i) really is a awesome editor 😊.

### 1.6 Import Pictures

Use `! [Alt text] (/path/to/img.jpg)` Import Pictures. among them:

* `Alt text` to text if the image is not displayed;
* `/Path/to/img.jpg` as a picture of the path;

Click the Add image keypad buttons, **MarkLite** will automatically help you to upload pictures to the image storage server, and insert link

Example

```
![MarkLite](http://i1.piimg.com/567954/ea65f02e0cd670a4.jpg)
```

![MarkLite](http://i1.piimg.com/567954/ea65f02e0cd670a4.jpg)

#### 1.7 bold and italic

1. Use `**` `__` for bold.
2. Use `*` or `_` italics.

Example

```
 ** 1 ** bold bold equal to ___ __
 * 1 * _ italic italics 2_
```

Bold Bold 2 ** 1 **

__italic italics__

#### 1.8 List

Use `1. 2 . 3.` represents an ordered list, or use the` * `,` + `,` -` unordered list.

1. unordered list or an ordered list of tags must be separated by a space and the following text.
2. ordered list tags are not in accordance with what you write digital display, but according to the current location marker displays an ordered list, as shown in Example 1.
3. bulleted unordered list is based on a solid round, open circles, solid squares progressive hierarchy, as shown in Example 2. Under normal circumstances, the same level using the same numerals, easy to view and manage their own.
4. unordered lists and ordered lists tag usage scenario is very clear, no more to say.

#### Example 1: An ordered list

```
1. The first point
2. The second point
4. third point
```

1. The first point
2. The second point
3. The third point

#### Example 2: unordered list

```
+ hehe
	* haha
	- lol
	- wow
		- meme
		+ zzzz
* hehe
```

*   haha

    *   hehe
    *   xixi
    *   wawa
        *   nono
        *   meme
*   haha

#### 1.9 dividing line

Use `---` or `***` or `* * *` denotes a horizontal dividing line.

1. As soon as `*` `-` greater than or equal to three can form a parallel line.

Example

```

---

***

* * *
```

#### 1.11 strikethrough

Use `~~` expressed strikethrough.

1. Note `~~` and not have to add a space between the strikethrough text.
2. I often used to display a line of text telling myself is to be deleted.

Example

```
~This is a strikethrough~
```

~This is a strikethrough~
