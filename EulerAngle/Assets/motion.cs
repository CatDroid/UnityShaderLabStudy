using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class motion : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
         Debug.Log("hello unity");
    }


    private float mLastTime = 0;
    private bool runOnce = false;
    private float y = 0;
    private float z = 0;
    // Update is called once per frame
    void Update()
    {
       
        Vector3 r0;
        r0.x = 0;
        r0.y = 0;
        r0.z = 90;
        transform.Rotate(r0, Space.Self);

        if (runOnce)
        {
            runOnce = false;

            Vector3 r1;
#if true


            r1.x = 0;
            r1.y = 0;
            r1.z = 90;
            transform.Rotate(r1, Space.Self);


            r1.x = 0;
            r1.y = 90; 
            r1.z = 0;
            transform.Rotate(r1, Space.Self);


            r1.x = 0;
            r1.y = 90; 
            r1.z = 0;
            transform.Rotate(r1, Space.Self);


#else 
            r1.x = 0;
            r1.y = 90;
            r1.z = 90;
            transform.Rotate(r1, Space.Self);
#endif
        }
       


#if false

        if (y <= 90)
        {
            

            float now = Time.time;

            //Debug.Log(string.Format("now={0} seconds ", now));

            if (mLastTime == 0)
            {
                mLastTime = now;
            }
            if (now - mLastTime > 0.1)
            {
                mLastTime = now;

                y++;

                 Vector3 r1;
                 r1.x = 0;
                 r1.y = y * 3.14f / 180.0f;
                 r1.z = 0;
                 transform.Rotate(r1, Space.Self);
               
            }

        } else if (z <= 90)
        {
            float now = Time.time;

            if (mLastTime == 0)
            {
                mLastTime = now;
            }
            if (now - mLastTime > 0.1)
            {
                mLastTime = now;

                z++;

                Vector3 r1;
                r1.x = 0;
                r1.y = y * 3.14f / 180.0f;
                r1.z = z * 3.14f / 180.0f;
                transform.Rotate(r1, Space.Self);
                
            }
        }
#endif

    }
}
