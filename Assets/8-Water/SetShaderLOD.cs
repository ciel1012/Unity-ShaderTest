using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetShaderLOD : MonoBehaviour
{
    public int ShaderLODNUM = 500;
    private Shader thisShader;
    // Start is called before the first frame update
    void Start()
    {
        thisShader = this.GetComponent<MeshRenderer>().material.shader;
        thisShader.maximumLOD = ShaderLODNUM;
        //Shader.globalMaximumLOD = ShaderLODNUM;
    }

    // Update is called once per frame
    void Update()
    {
        thisShader.maximumLOD = ShaderLODNUM;
        //Shader.globalMaximumLOD = ShaderLODNUM;
    }
}
