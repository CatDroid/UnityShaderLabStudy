



### 不透明物体渲染，需要关闭深度写入的原因

[半透明物体互相交叉]: https://github.com/candycat1992/Unity_Shaders_Book/issues/153

* 传统的半透明混合总是会在物体交叉、渲染重叠的情况下，出现错误的混合效果。如果开启深度写入，会令到渲染错误很明显，而关掉的话影响较小一点



### 开启深度写入的半透明效果

[为什么半透明模型的渲染要使用深度测试而关闭深度写入]: https://www.zhihu.com/question/60898307

* 深度测试的意义在于舍弃片元与否。

* 深度写入的意义在于深度测试的基础上，要不要覆盖深度缓冲，即重新设立深度测试的标准。

* 对于半透明的渲染， 是可以同时开启深度测试和深度写入的。方法是使用2个Pass。一个先只负责保证像素级片元深度正确，一个负责渲染 (左边)

* 如果没有配合深度写入来保证像素级的深度关系 （右边，关闭深度写入,直接透明混合）

  ![img](深度写入保证像素级深度关系.jpg) 

