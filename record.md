### 解决s_r冲突

根据 [parser.output](vscode-file://vscode-app/usr/share/code/resources/app/out/vs/code/electron-sandbox/workbench/workbench.html) 文件的分析，你的语法中有  **13 个 shift/reduce 冲突** ，全部都出现在  **state 76** ，这是由于 **运算符结合性** 问题导致的。

#### 问题分析

在 state 76 中，解析器遇到了这样的情况：

**expr : expr . binop expr  (31)**

**expr : expr binop expr .  (31)**

当遇到运算符时，解析器不知道应该：

* **shift** ：继续读取下一个运算符（左结合）
* **reduce** ：先完成当前表达式（右结合）

#### 根本原因

你的 `parser.mly` 中，`binop` 规则没有直接使用优先级声明，而是通过一个单独的 `binop` 非终结符。这导致优先级声明失效。

#### 解决方案

将 `binop` 规则直接内联到 `expr` 规则中，让优先级声明生效：

**expr**:

**  **|** **NUM** **{** **Num** **$**1** **}**

**  **|** **ID** **{** **Var** **$**1** **}**

**  **|** **LPAREN** expr **RPAREN** **{** **$**2** **}**

**  **|** **SUB** expr %prec UMINUS **{** Neg $2 **}

**  | NOT expr **{** Not $2 **}

**  | expr ADD expr **{** Binop **(**$1, Add, $3**)** **}

**  | expr SUB expr **{** Binop **(**$1, Sub, $3**)** **}

**  | expr MUL expr **{** Binop **(**$1, Mul, $3**)** **}

**  | expr DIV expr **{** Binop **(**$1, Div, $3**)** **}

**  | expr MOD expr **{** Binop **(**$1, Mod, $3**)** **}

**  | expr EQ expr **{** Binop **(**$1, Eq, $3**)** **}

**  | expr NE expr **{** Binop **(**$1, Ne, $3**)** **}

**  | expr LT expr **{** Binop **(**$1, Lt, $3**)** **}

**  | expr GT expr **{** Binop **(**$1, Gt, $3**)** **}

**  | expr LE expr **{** Binop **(**$1, Le, $3**)** **}

**  | expr GE expr **{** Binop **(**$1, Ge, $3**)** **}

**  | expr AND expr **{** Binop **(**$1, And, $3**)** **}

**  | expr OR expr **{** Binop **(**$1, Or, $3**)** **}

**  | ID LPAREN args RPAREN **{** Call **(**$1, $3**)** **}

然后 **删除** `binop` 规则：

**(* 删除这个规则 *)**

**binop**:

**  **|** **ADD** **{** **Add** **}

**  **|** **SUB** **{** **Sub** **}

**  **(* ... *)

## 修改后的完整 `expr` 部分

**expr**:

**  **|** **NUM** **{** **Num** **$**1** **}**

**  **|** **ID** **{** **Var** **$**1** **}**

**  **|** **LPAREN** expr **RPAREN** **{** **$**2** **}**

**  **|** **SUB** expr %prec UMINUS **{** Neg $2 **}

**  | NOT expr **{** Not $2 **}

**  | expr ADD expr **{** Binop **(**$1, Add, $3**)** **}

**  | expr SUB expr **{** Binop **(**$1, Sub, $3**)** **}

**  | expr MUL expr **{** Binop **(**$1, Mul, $3**)** **}

**  | expr DIV expr **{** Binop **(**$1, Div, $3**)** **}

**  | expr MOD expr **{** Binop **(**$1, Mod, $3**)** **}

**  | expr EQ expr **{** Binop **(**$1, Eq, $3**)** **}

**  | expr NE expr **{** Binop **(**$1, Ne, $3**)** **}

**  | expr LT expr **{** Binop **(**$1, Lt, $3**)** **}

**  | expr GT expr **{** Binop **(**$1, Gt, $3**)** **}

**  | expr LE expr **{** Binop **(**$1, Le, $3**)** **}

**  | expr GE expr **{** Binop **(**$1, Ge, $3**)** **}

**  | expr AND expr **{** Binop **(**$1, And, $3**)** **}

**  | expr OR expr **{** Binop **(**$1, Or, $3**)** **}

**  | ID LPAREN args RPAREN **{** Call **(**$1, $3**)** **}

**(* 删除 binop 规则 *)**

这样修改后，所有运算符的优先级和结合性声明将正确生效，13 个 shift/reduce 冲突应该全部消失。

### 超八个参数传递

#### 问题分析

##### 1. 函数调用参数传递错误

 **RISC-V 调用约定** ：前8个参数通过 `a0-a7` 寄存器传递，超过8个的参数通过栈传递。

但在你的汇编代码中，函数参数超过8个时，生成的代码有问题：

**# sum16 调用 - 有16个参数**

**call sum16**

**addi sp, sp, 32    # 这里恢复了32字节，但实际只压了8个参数(32字节)**

### 2. 栈平衡问题

在 `sum64` 调用中：

**call sum64**

**addi sp, sp, 224   # 恢复224字节，但可能压栈的字节数不匹配**

这表明你的代码生成器在处理**超过8个参数的函数调用**时，栈操作不正确。

##### 根本原因

 **`codegen.ml` 中的 `Call` 表达式生成有Bug** ：

**|** **Call** **(**fname**,** args**)** **->**

**    **let** **n** **=** **List**.**length args **in**

**    **List**.**iteri **(**fun** i arg **->

**      gen_expr env oc arg**;

**      **if** i **<** **8** **then

**        **Printf**.**fprintf oc **"  mv a**%d**, **%s\n**"** i t0

**      **else** **(

**        **Printf**.**fprintf oc **"  addi **%s**, **%s**, -4**\n**"** sp sp**;**

**        **Printf**.**fprintf oc **"  sw **%s**, 0(**%s**)**\n**"** t0 sp

**      **)

**    **)** args**;

**    **Printf**.**fprintf oc **"  call **%s\n**"** fname**;**

**    **if** n **>** **8** **then

**      **Printf**.**fprintf oc **"  addi **%s**, **%s**, **%d\n**"** sp sp **(**(**n**-**8**)*****4**)**;**  **(* 这里有问题 *)

#### 修复方案

修改 `codegen.ml` 中的函数调用代码生成：

**|** **Call** **(**fname**,** args**)** **->**

**    **let** **n** **=** **List**.**length args **in**

**    **(* 计算需要通过栈传递的参数数量 *)

**    **let** **stack_args** **=** max **0** **(**n **-** **8**)** **in**

---

**    **(* 生成参数代码 *)

**    **List**.**iteri **(**fun** i arg **->

**      gen_expr env oc arg**;

**      **if** i **<** **8** **then

**        **Printf**.**fprintf oc **"  mv a**%d**, **%s\n**"** i t0

**      **else** **(

**        **Printf**.**fprintf oc **"  addi **%s**, **%s**, -4**\n**"** sp sp**;**

**        **Printf**.**fprintf oc **"  sw **%s**, 0(**%s**)**\n**"** t0 sp

**      **)

**    **)** args**;

---

**    **(* 调用函数 *)

**    **Printf**.**fprintf oc **"  call **%s\n**"** fname**;**

---

**    **(* 恢复栈指针 - 只恢复超过8个参数的部分 *)

**    **if** stack_args **>** **0** **then

**      **Printf**.**fprintf oc **"  addi **%s**, **%s**, **%d\n**"** sp sp **(**stack_args ***** **4**)**;**

---

**    **Printf**.**fprintf oc **"  mv **%s**, **%s\n**"** t0 a0

### 没有else的if分支

### "int x;"(初始化未赋值)

### "/* /* */"嵌套注释
