
### 如何插入公式

LaTeX的数学公式有两种：行中公式和独立公式。行中公式放在文中与其它文字混编，独立公式单独成行。

例子:

```
$[J_\alpha(x) = \sum_{m=0}^\infty \frac{(-1)^m}{m! \Gamma (m + \alpha + 1)} {\left({ \frac{x}{2} }\right)}^{2m + \alpha} ]$
```

显示： $[J_\alpha(x) = \sum_{m=0}^\infty \frac{(-1)^m}{m! \Gamma (m + \alpha + 1)} {\left({ \frac{x}{2} }\right)}^{2m + \alpha} ]$

### 如何插入公式大括号

矩阵：

```
$$\begin{bmatrix} 1&x&x^2\\\\ 1&y&y^2\\\\ 1&z&z^2 \end{bmatrix}$$ 
vmatrix ||、Bmatrix{}、pmatrix()
```

分段函数:

```
$$f(x)=
\begin{cases}
0& \text{x=0}\\\\
1& \text{x!=0}
\end{cases}$$
```
矩阵：$$\begin{bmatrix} 1&x&x^2\\\\ 1&y&y^2\\\\ 1&z&z^2 \end{bmatrix}$$ 
vmatrix ||、Bmatrix{}、pmatrix()}

分段函数：
$$f(x)=
\begin{cases}
0& \text{x=0}\\\\
1& \text{x!=0}
\end{cases}$$

### 如何输入上下标

^表示上标, _表示下标。如果上下标的内容多于一个字符，要用{}把这些内容括起来当成一个整体。上下标是可以嵌套的，也可以同时使用。

例子：

```
$x^{y^z}=(1+{\rm e}^x)^{-2xy^w}$
```

显示：$x^{y^z}=(1+{\rm e}^x)^{-2xy^w}$

另外，如果要在左右两边都有上下标，可以用\sideset命令。

例子：

```
$\sideset{^1_2}{^3_4}\bigotimes$
```

显示：$\sideset{^1_2}{^3_4}\bigotimes$

$ \max_{k} $
$ \mathop{argmax}_{K} $
    
### 如何输入括号和分隔符

()、[]和|表示自己，{}表示{}。当要显示大号的括号或分隔符时，要用\left和\right命令。

例子：

```
$f(x,y,z) = 3y^2z \left( 3+\frac{7x+5}{1+y^2} \right)$
```

显示：$f(x,y,z) = 3y^2z \left( 3+\frac{7x+5}{1+y^2} \right)$

有时候要用\left.或\right.进行匹配而不显示本身。

例子：

```
$\left. \frac{{\rm d}u}{{\rm d}x} \right| _{x=0}$
```

显示：$ \left. \frac{{\rm d}u}{{\rm d}x} \right| _{x=0} $

### 如何输入分数

例子：`$\frac{1}{3}$　或　$1 \over 3$`

显示：$\frac{1}{3}$　或　$1 \over 3$

### 如何输入开方

例子：`$\sqrt{2}$　和　$\sqrt[n]{3}$`

显示：$\sqrt{2}$　和　$\sqrt[n]{3}$

### 如何输入省略号

数学公式中常见的省略号有两种，\ldots表示与文本底线对齐的省略号，\cdots表示与文本中线对齐的省略号。

例子：

```
$f(x_1,x_2,\ldots,x_n) = x_1^2 + x_2^2 + \cdots + x_n^2$
```

显示：$f(x_1,x_2,\ldots,x_n) = x_1^2 + x_2^2 + \cdots + x_n^2$

### 如何输入矢量

例子：`$\vec{a} \cdot \vec{b}=0$`

显示：$\vec{a} \cdot \vec{b}=0$

### 如何输入积分

例子：`$\int_0^1 x^2 {\rm d}x$`

显示：$\int_0^1 x^2 {\rm d}x$

### 如何输入极限运算

例子：

```
$\lim\limits_{n \rightarrow +\infty} \frac{1}{n(n+1)}$ 
```

显示：
$\lim\limits_{n \rightarrow +\infty} \frac{1}{n(n+1)}$ 

### 如何输入累加、累乘运算

例子：

```
$$\sum_{i=0}^n \frac{1}{i^2}$　和　$\prod_{i=0}^n \frac{1}{i^2}$$
```

显示：$$\sum_{i=0}^n \frac{1}{i^2}$　和　$\prod_{i=0}^n \frac{1}{i^2}$$

### 如何进行公式应用

例子：

```
$r = r_F+ \beta(r_M – r_F) + \epsilon$
```

显示： $r = r_F+ \beta(r_M – r_F) + \epsilon$

### 如何输入希腊字母

\alpha　A　\beta　B　\gamma　\Gamma　\delta　\Delta　\epsilon　E 
\varepsilon　　\zeta　Z　\eta　H　\theta　\Theta　\vartheta 
\iota　I　\kappa　K　\lambda　\Lambda　\mu　M　\nu　N 
\xi　\Xi　o　O　\pi　\Pi　\varpi　　\rho　P 
\varrho　　\sigma　\Sigma　\varsigma　　\tau　T　\upsilon　\Upsilon 
\phi　\Phi　\varphi　　\chi　X　\psi　\Psi　\omega　\Omega


### 如何输入其它特殊字符
关系运算符：

±：\pm 
×：\times 
÷：\div 
∣：\mid 
∤：\nmid 
⋅：\cdot 
∘：\circ 
∗：\ast 
⨀：\bigodot 
⨂：\bigotimes 
⨁：\bigoplus 
≤：\leq 
≥：\geq 
≠：\neq 
≈：\approx 
≡：\equiv 
∑：\sum 
∏：\prod 
∐：\coprod

集合运算符：

∅：\emptyset 
∈：\in 
∉：\notin 
⊂：\subset 
⊃：\supset 
⊆：\subseteq 
⊇：\supseteq 
⋂：\bigcap 
⋃：\bigcup 
⋁：\bigvee 
⋀：\bigwedge 
⨄：\biguplus 
⨆：\bigsqcup


对数运算符：


log：\log 
lg：\lg 
ln：\ln

三角运算符：

⊥：\bot 
∠：\angle 
30∘：30^\circ 
sin：\sin 
cos：\cos 
tan：\tan 
cot：\cot 
sec：\sec 
csc：\csc


微积分运算符：


′：\prime 
∫：\int 
∬：\iint 
∭：\iiint 
⨌：\iiiint 
∮：\oint 
lim：\lim 
∞：\infty 
∇：\nabla


逻辑运算符：

∵：\because 
∴：\therefore 
∀：\forall 
∃：\exists 
≠：\not= 
≯：\not> 
⊄：\not\subset


戴帽符号:


：\hat{y} 
：\check{y} 
：\breve{y}


连线符号：

：\overline{a+b+c+d} 
：\underline{a+b+c+d} 
：\overbrace{a+\underbrace{b+c}_{1.0}+d}^{2.0}


箭头符号：

↑：\uparrow 
↓：\downarrow 
⇑：\Uparrow 
⇓：\Downarrow 
→：\rightarrow 
←：\leftarrow 
⇒：\Rightarrow 
⇐：\Leftarrow 
⟶：\longrightarrow 
⟵：\longleftarrow 
⟹：\Longrightarrow 
⟸：\Longleftarrow

### 如何进行字体转换

要对公式的某一部分字符进行字体转换，可以用{\rm 需转换的部分字符}命令，其中\rm可以参照下表选择合适的字体。一般情况下，公式默认为意大利体。


\rm　　罗马体　　　　　　　\it　　意大利体 
\bf　　黑体　　　　　　　　\cal 　花体 
\sl　　倾斜体　　　　　　　\sf　　等线体 
\mit 　数学斜体　　　　　　\tt　　打字机字体 
\sc　　小体大写字母

