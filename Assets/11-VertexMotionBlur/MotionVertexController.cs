using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionVertexController : MonoBehaviour
{
    private Transform trans;
    private Material[] mats;
    private Vector3 lastPosition;
    private Vector3 newPosition;
    private Vector3 direction;
    private float t = 0;

    void Start()
    {
        trans = transform;
        lastPosition = newPosition = trans.position;

        //获取对象及子对象中的所有渲染器（MeshRenderer或者SkinnedMeshRenderer）
        var renderers = trans.GetComponentsInChildren<Renderer>();
        //获取所有的材质球(针对有些对象有多个部件多个材质的情况)
        mats = new Material[renderers.Length];
        for (int i = 0; i < renderers.Length; i++)
        {
            mats[i] = renderers[i].sharedMaterial;
        }
    }

    void Update()
    {
        newPosition = trans.position;

        //如果上一帧的位置追到了当前帧的位置，则重置t
        if (newPosition == lastPosition) t = 0;
        t += Time.deltaTime;
        //上一帧的位置通过t来做插值
        lastPosition = Vector3.Lerp(lastPosition, newPosition, t / 2);
        //求出移动的方向
        direction = lastPosition - newPosition;
        //遍历修改所有材质的_Direction属性
        foreach (var m in mats)
        {
            m.SetVector("_Direction", new Vector4(direction.x, direction.y, direction.z, m.GetVector("_Direction").w));
        }
    }

}