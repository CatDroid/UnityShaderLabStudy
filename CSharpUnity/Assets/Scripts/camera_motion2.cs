using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class camera_motion2 : MonoBehaviour {

    GameObject cube1;
    GameObject cube2;
    GameObject cube3;


    // Use this for initialization
    void Start () {

        // 如果使用脚本自动绑定物体
        cube1 = GameObject.Find("Cube1");
        cube2 = GameObject.Find("Cube2");
        cube3 = GameObject.Find("Cube3");


    }

    // Update is called once per frame
    void Update () {
        cube1.transform.Translate(Vector3.up * 0.1f * Mathf.Sin(Time.time) , Space.World); // 每执行一次 都是在之前的位置/状态上移动 
        cube2.transform.Rotate(Vector3.up * 1, Space.Self);
        cube3.transform.localScale = new Vector3(1 + Mathf.Sin(Time.time), 1 + Mathf.Sin(Time.time), 1 + Mathf.Sin(Time.time));
    }
}
