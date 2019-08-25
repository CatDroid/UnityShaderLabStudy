



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

* Unity3d 中 Quad 是一个平面正方形 ，Unity在默认情况下渲染引擎剔除了物体背面，如果Quad能够在Scene场景被看到，应该是一个内部有颜色的正方形，如果对着” Scene场景摄像机” 是 Quad的背面的话，点击Quad物体，看到只是一个框

* Unity3d 区别与OpenGL 

  * 默认背面剔除
  * 默认是顺时针表示正面，逆时针表示背面

![1566701041382](Quad正面对着场景摄像机.png)

![1566701118451](Quad背面对着场景摄像机.png)

### Unity3d 摄像机

* 摄像机沿着自己的z轴旋转，不会影响场景中物体/三角形在镜头前的正面和背(现实世界也是，旋转手机不会导致前方物体的朝着摄像机的一面发生变化)

* 每个摄像机可以设置不同的Target Display，在GameView中可以选择不同的Display，从而可以看到不同摄像机的画面

* 留意摄像机的z轴方向是对应世界坐标系中的那个轴

  

### Unity3D 旋转正方向

* 旋转正方向是左手螺旋法则





### 总结

* 透明度双面渲染---- 先后分别打开cull front和cull back 面剔除 后渲染个一次 ---- 应用于，显示透明物体内部
* 打开深度写入的半透明效果--- 先关闭colormask写入打开深度写入，渲染一次模型后，再打开color写入关闭深度写入但保持深度检测，再渲染一次模型----- 应用于，模型本身有复杂遮挡关系