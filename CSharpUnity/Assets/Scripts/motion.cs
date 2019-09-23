using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class motion : MonoBehaviour {

	// Use this for initialization
	void Start () {
        Debug.Log("hello unity");
    }

    // Update is called once per frame
    static bool runOnce = false;
	void Update ()
    {

        // “this”，它指的是脚本被绑定的那个物体

        if (!runOnce)
        {
            runOnce = true ;

            // up	 Shorthand for writing Vector3(0, 1, 0).
            //this.transform.Rotate(Vector3.up * 90, Space.Self);

            // right Shorthand for writing Vector3(1, 0, 0).
            //this.transform.Rotate(Vector3.right * 90, Space.Self); // 在上一个状态更新之后 
        }

        this.transform.Rotate(Vector3.up * Mathf.Sin(Time.time), Space.Self);

    }
}
