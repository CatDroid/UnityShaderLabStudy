



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



### Aplha 透明度测试

* 透明度边界处有锯齿，所以透明效果在边缘处参差不齐，因为边界处纹理的透明度的变化精度问题

![1566087896832](透明度边界处有锯齿.png)



### 复杂遮挡关系的模型 使用 开启深度写入的半透明效果

* 开启深度写入的半透明效果: 第一打开深度写入 关闭颜色写入ColorMask 0 ; 第二次关闭深度写入 打开颜色写入 

* 这样可以处理 模型本身有复杂的遮挡关系，或者包含复杂的非凸网络的时候

* 因为在cpu端，无法对模型进行像素级排序

* 在unity中，可以不自己写shader来实现模型深度写入，SubShader会一个个Pass执行

  ```
  		Pass
  		{
  			ZWrite On
  			ColorMask 0  // ColorMask A | RGB | 0 
  			// 不需要shader去做片元着色 只是写入深度信息
  		} 
  		Pass
  		{
               Tags 
  			{
  				"LightMode" = "ForwardBase"
  			}
  			ZWrite Off
  			ColorMask RGBA
  			Blend SrcAlpha OneMinusSrcAlpha
  			
  			CGPROGRAM
  			..... 片元和顶点着色器 
  			ENDCG
  			
  		}
  ```






### 面剔除

* [面剔除 Face culling]: https://learnopengl-cn.readthedocs.io/zh/latest/04%20Advanced%20OpenGL/04%20Face%20culling/

* 三个设置

  * 设置正面是逆时针 ( 默认 glFrontFace(GL_CCW); ) ，还是顺时针( GL_CW )，
  * 剔除正面还是反面 (  glCullFace(GL_BACK);  ) 
  * 开关面剔除 glEnable( GL_CULL_FACE );  默认关闭 

* Unity3d 中 Quad 是一个平面正方形 ，Unity在默认情况下渲染引擎剔除了物体背面

