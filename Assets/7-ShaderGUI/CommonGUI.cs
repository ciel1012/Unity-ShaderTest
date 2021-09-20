using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class CommonGUI : ShaderGUI {

    private static class Styles
    {
        public static GUIContent DiffuseTextureText = new GUIContent("漫反射贴图");
        public static GUIContent NormalText = new GUIContent("法线");
        public static GUIContent NormalTextureText = new GUIContent("法线贴图");
        public static GUIContent EmissionText = new GUIContent("自发光");
        public static GUIContent EmissionMaskText = new GUIContent("遮罩图");
        public static GUIContent EmissionColorText = new GUIContent("自发光颜色");
        public static GUIContent EmissionStrengthText = new GUIContent("自放光强度");
    }

    MaterialProperty _MainTex = null;
    MaterialProperty _Normal = null;
    MaterialProperty _NormalLayerShown = null;
    MaterialProperty _NormalTex = null;
    MaterialProperty _Emission = null;
    MaterialProperty _EmissionLayerShown = null;
    MaterialProperty _MaskTex = null;
    MaterialProperty _EmissionColor = null;
    MaterialProperty _EmissinStrength = null;

    MaterialEditor m_MaterialEditor;

    public void FindProperties(MaterialProperty[] props)
    {
        _MainTex = FindProperty("_MainTex",props);
        _Normal = FindProperty("_Normal",props);
        _NormalLayerShown = FindProperty("_NormalLayerShown",props);
        _NormalTex = FindProperty("_BumpMap",props);
        _Emission = FindProperty("_Emission",props);
        _EmissionLayerShown = FindProperty("_EmissionLayerShown", props);
        _MaskTex = FindProperty("_MaskTex", props);
        _EmissionColor = FindProperty("_EmissionColor",props);
        _EmissinStrength = FindProperty("_Strength",props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        FindProperties(props);
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;
        ShaderPropertiesGUI(material);//主要面板显示方法，在后面有定义
    }

    public void ShaderPropertiesGUI(Material material)
    {
        // 使用默认标签宽度
        EditorGUIUtility.labelWidth = 0f;
        // 检测材质的任何变化
        EditorGUI.BeginChangeCheck();
        {
            //Main贴图设置
            m_MaterialEditor.TexturePropertySingleLine(Styles.DiffuseTextureText,_MainTex);
            m_MaterialEditor.TextureScaleOffsetProperty(_MainTex);
        }
        //改变UI背景色
        GUI.backgroundColor = new Color(1.0f, 1.0f, 1.0f, 0.5f);
        //添加法线相关按钮
        EditorGUILayout.BeginVertical("Button");
        {
            EditorGUI.showMixedValue = _Normal.hasMixedValue;
            float nval;
            EditorGUI.BeginChangeCheck();
            if (_Normal.floatValue == 1)
            {
                material.EnableKeyword("_NORMAL_ON");
                nval = EditorGUILayout.ToggleLeft(Styles.NormalText, _Normal.floatValue == 1, GUILayout.Width(EditorGUIUtility.currentViewWidth-60)) ? 1 : 0;
            }
            else
            {
                material.DisableKeyword("_NORMAL_ON");
                nval = EditorGUILayout.ToggleLeft(Styles.NormalText, _Normal.floatValue == 1) ? 1 : 0;
            }
            if (EditorGUI.EndChangeCheck())
            {
                _Normal.floatValue = nval;
            }
            EditorGUI.showMixedValue = false;
        }
        // 显示或隐藏板块
        if (_Normal.floatValue == 1)
        {
            Rect rect = GUILayoutUtility.GetLastRect();
            rect.x += EditorGUIUtility.currentViewWidth - 47;//显示隐藏按钮（小三角形）位置

            EditorGUI.BeginChangeCheck();
            float nval = EditorGUI.Foldout(rect, _NormalLayerShown.floatValue == 1, "") ? 1 : 0;
            if (EditorGUI.EndChangeCheck())
            {
                _NormalLayerShown.floatValue = nval;
            }
        }
        //显示法线贴图设置
        if (_Normal.floatValue == 1 && (_NormalLayerShown.floatValue == 1 || _NormalLayerShown.hasMixedValue))
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.NormalTextureText, _NormalTex);
        }
        EditorGUILayout.EndVertical();

        //添加自发光相关按钮
        EditorGUILayout.BeginVertical("Button");
        {
            EditorGUI.showMixedValue = _Emission.hasMixedValue;
            float nval;
            EditorGUI.BeginChangeCheck();
            if (_Emission.floatValue == 1)
            {
                material.EnableKeyword("_EMISSION_ON");
                nval = EditorGUILayout.ToggleLeft(Styles.EmissionText, _Emission.floatValue == 1, EditorStyles.boldLabel, GUILayout.Width(EditorGUIUtility.currentViewWidth - 60)) ? 1 : 0;
            }
            else
            {
                material.DisableKeyword("_EMISSION_ON");
                nval = EditorGUILayout.ToggleLeft(Styles.EmissionText, _Emission.floatValue == 1, EditorStyles.boldLabel) ? 1 : 0;
            }
            if (EditorGUI.EndChangeCheck())
            {
                _Emission.floatValue = nval;
            }
            EditorGUI.showMixedValue = false;
        }
        //显示或隐藏板块
        if (_Emission.floatValue == 1)
        {
            Rect rect = GUILayoutUtility.GetLastRect();
            rect.x += EditorGUIUtility.currentViewWidth - 47;
            //rect.height-=EditorGUIUtility.singleLineHeight;

            EditorGUI.BeginChangeCheck();
            float nval = EditorGUI.Foldout(rect, _EmissionLayerShown.floatValue == 1, "") ? 1 : 0;
            if (EditorGUI.EndChangeCheck())
            {
                _EmissionLayerShown.floatValue = nval;
            }
        }
        //显示自法光属性设置
        if (_Emission.floatValue == 1 && (_EmissionLayerShown.floatValue == 1 || _EmissionLayerShown.hasMixedValue))
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.EmissionMaskText, _MaskTex);
            m_MaterialEditor.ShaderProperty(_EmissionColor, Styles.EmissionColorText, 0);
            m_MaterialEditor.ShaderProperty(_EmissinStrength,Styles.EmissionStrengthText,0);
        }
        EditorGUILayout.EndVertical();
    }
}
