using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class capsule_lifttime : MonoBehaviour
{

    void Awake() // 跟 OnDestory 一定会调用 类似构造和析构函数
    {
        Debug.Log("----Awake-----");
    }

    // Start is called before the first frame update
    void Start()
    {
        Debug.LogWarning("----Start Warning-----");
        //Debug.LogError("----Start Error----");
    }

    // Update is called once per frame
    void Update()
    {
        Debug.Log("----Update-----");
    }

    // 所有update完成后调用 比如游戏对象在Update中更新位置,摄像机在LateUpdate中跟随
    void LateUpdate()
    {

    }

    // 固定间隔执行 默认调用间隔在0.02s TimeManager 用于匀速运动
    void FixedUpdate()
    {

    }


    // 脚本被使能和禁止
    void OnEnable()  // 比start还要早
    {
        Debug.LogWarning("onEnable");
    }

    // 脚本disable之后 update就不会执行
    void OnDisable()
    {
        Debug.LogWarning("onDisable");
    }

    void OnGUI()
    {
        // 绘制界面函数 UGUI 这个回调一般用在测试功能使用 创建测试按钮 
    }

    void OnDestroy() // stop的时候会调用
    {
        Debug.LogWarning("OnDestroy");
    }


}
