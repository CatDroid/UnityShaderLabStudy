using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class camera_motion1 : MonoBehaviour {
 
    public GameObject cube1;
    public GameObject cube2;
    public GameObject cube3;


    // Use this for initialization
    void Start () {
		
	}

    /*

        如果我们要控制多个物体，就需要使用公有变量绑定物体或使用脚本动态寻找物体。

        在场景中创建3个Cube，分别是Cube1，Cube2，Cube3。
        
        将写好的脚本绑定到"摄像机"上


    */
    // Update is called once per frame
    void Update () {
        cube1.transform.Translate(Vector3.up * 0.1f, Space.World);
        cube2.transform.Rotate(Vector3.up * 1, Space.Self);
        cube3.transform.localScale = new Vector3(1 + Mathf.Sin(Time.time), 1 + Mathf.Sin(Time.time), 1 + Mathf.Sin(Time.time));
    }
}
