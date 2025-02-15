// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace AmplifyShaderEditor
{
	[Serializable]
	public sealed class TemplateMultiPass : TemplateDataParent
	{
		[SerializeField]
		private List<TemplateShaderPropertyData> m_availableShaderProperties = new List<TemplateShaderPropertyData>();
		
		[SerializeField]
		private List<TemplateSubShader> m_subShaders = new List<TemplateSubShader>();

		[SerializeField]
		private TemplateTagData m_propertyTag;

		[SerializeField]
		private TemplateIdManager m_templateIdManager;
		
		[SerializeField]
		private string m_shaderNameId = string.Empty;
	
		[SerializeField]
		private string m_shaderBody;

		[SerializeField]
		private TemplatePropertyContainer m_templateProperties = new TemplatePropertyContainer();

		[SerializeField]
		private TemplateShaderInfo m_shaderData;

		[SerializeField]
		private bool m_isSinglePass = false;

		[SerializeField]
		private int m_masterNodesRequired = 0;

		public TemplateMultiPass( string name, string guid ) : base( TemplateDataType.MultiPass )
		{
			TemplatesManager.CurrTemplateGUIDLoaded = guid;
			LoadTemplateBody( guid );
			m_name = string.IsNullOrEmpty( name ) ? m_defaultShaderName : name;
		}

		void LoadTemplateBody( string guid )
		{
			m_guid = guid;
			string datapath = AssetDatabase.GUIDToAssetPath( guid );
			string shaderBody = string.Empty;
			shaderBody = IOUtils.LoadTextFileFromDisk( datapath );
			shaderBody = shaderBody.Replace( "\r\n", "\n" );
			m_shaderData = TemplateShaderInfoUtil.CreateShaderData( shaderBody );
			if( m_shaderData == null )
			{
				m_isValid = false;
				return;
			}

			m_templateIdManager = new TemplateIdManager( shaderBody );

			try
			{
				int nameBegin = shaderBody.IndexOf( TemplatesManager.TemplateShaderNameBeginTag );
				if( nameBegin < 0 )
				{
					// Not a template
					return;
				}

				m_shaderBody = shaderBody;
				int nameEnd = shaderBody.IndexOf( TemplatesManager.TemplateFullEndTag, nameBegin );
				int defaultBegin = nameBegin + TemplatesManager.TemplateShaderNameBeginTag.Length;
				int defaultLength = nameEnd - defaultBegin;
				m_defaultShaderName = shaderBody.Substring( defaultBegin, defaultLength );
				int[] nameIdx = m_defaultShaderName.AllIndexesOf( "\"" );
				nameIdx[ 0 ] += 1; // Ignore the " character from the string
				m_defaultShaderName = m_defaultShaderName.Substring( nameIdx[ 0 ], nameIdx[ 1 ] - nameIdx[ 0 ] );
				m_shaderNameId = shaderBody.Substring( nameBegin, nameEnd + TemplatesManager.TemplateFullEndTag.Length - nameBegin );
				m_templateProperties.AddId( shaderBody, m_shaderNameId, false );
				m_templateIdManager.RegisterId( nameBegin, m_shaderNameId, m_shaderNameId );
			}
			catch( Exception e )
			{
				Debug.LogException( e );
				m_isValid = false;
			}

			m_propertyTag = new TemplateTagData( m_shaderData.PropertyStartIdx, TemplatesManager.TemplatePropertyTag, true );
			m_templateIdManager.RegisterId( m_shaderData.PropertyStartIdx, TemplatesManager.TemplatePropertyTag, TemplatesManager.TemplatePropertyTag );
			m_templateProperties.AddId( shaderBody, TemplatesManager.TemplatePropertyTag, true );
			Dictionary<string, TemplateShaderPropertyData> duplicatesHelper = new Dictionary<string, TemplateShaderPropertyData>();
			TemplateHelperFunctions.CreateShaderPropertiesList( m_shaderData.Properties, ref m_availableShaderProperties, ref duplicatesHelper );
			int subShaderCount = m_shaderData.SubShaders.Count;
			for( int i = 0; i < subShaderCount; i++ )
			{
				TemplateSubShader subShader = new TemplateSubShader( i, m_templateIdManager, "SubShader" + i, m_shaderData.SubShaders[ i ], ref duplicatesHelper );
				m_subShaders.Add( subShader );
				m_masterNodesRequired += subShader.Passes.Count;
			}

			duplicatesHelper.Clear();
			duplicatesHelper = null;
			m_isSinglePass = ( m_subShaders.Count == 1 && m_subShaders[ 0 ].PassAmount == 1 );

		}

		public void Reset()
		{
			m_templateIdManager.ResetRegistersState();
			int subshaderCount = m_subShaders.Count;
			for( int subShaderIdx = 0; subShaderIdx < subshaderCount; subShaderIdx++ )
			{
				m_subShaders[ subShaderIdx ].TemplateProperties.ResetTemplateUsageData();
				int passCount = m_subShaders[ subShaderIdx ].Passes.Count;
				for( int passIdx = 0; passIdx < passCount; passIdx++ )
				{
					m_subShaders[ subShaderIdx ].Passes[ passIdx ].TemplateProperties.ResetTemplateUsageData();
				}
			}
		}

		public override void Destroy()
		{
			m_templateProperties.Destroy();
			m_templateProperties = null;
			
			m_availableShaderProperties.Clear();
			m_availableShaderProperties = null;

			int subShaderCount = m_subShaders.Count;
			for( int i = 0; i < subShaderCount; i++ )
			{
				m_subShaders[ i ].Destroy();
			}

			m_subShaders.Clear();
			m_subShaders = null;

			m_templateIdManager.Destroy();
			m_templateIdManager = null;
		}

		public void SetSubShaderData( TemplateModuleDataType type, int subShaderId, string[] list )
		{
			string id = GetSubShaderDataId( type, subShaderId, false );
			string body = string.Empty;
			FillTemplateBody( subShaderId, -1, id, ref body, list );
			SetSubShaderData( type, subShaderId, body );
		}

		public void SetSubShaderData( TemplateModuleDataType type, int subShaderId, List<PropertyDataCollector> list )
		{
			string id = GetSubShaderDataId( type, subShaderId, false );
			string body = string.Empty;
			FillTemplateBody( subShaderId, -1, id, ref body, list );
			SetSubShaderData( type, subShaderId, body );
		}

		public void SetSubShaderData( TemplateModuleDataType type, int subShaderId, string text )
		{
			if( subShaderId >= m_subShaders.Count )
				return;

			string prefix = m_subShaders[ subShaderId ].Modules.UniquePrefix;
			switch( type )
			{
				case TemplateModuleDataType.ModuleShaderModel:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.ShaderModel.Id, text );
				}
				break;
				case TemplateModuleDataType.ModuleBlendMode:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.BlendData.BlendModeId, text );
				}
				break;
				case TemplateModuleDataType.ModuleBlendOp:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.BlendData.BlendOpId, text );
				}
				break;
				case TemplateModuleDataType.ModuleCullMode:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.CullModeData.CullModeId, text );
				}
				break;
				case TemplateModuleDataType.ModuleColorMask:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.ColorMaskData.ColorMaskId, text );
				}
				break;
				case TemplateModuleDataType.ModuleStencil:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.StencilData.StencilBufferId, text );
				}
				break;
				case TemplateModuleDataType.ModuleZwrite:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.DepthData.ZWriteModeId, text );
				}
				break;
				case TemplateModuleDataType.ModuleZTest:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.DepthData.ZTestModeId, text );
				}
				break;
				case TemplateModuleDataType.ModuleZOffset:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.DepthData.OffsetId, text );
				}
				break;
				case TemplateModuleDataType.ModuleTag:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.TagData.TagsId, text );
				}
				break;
				case TemplateModuleDataType.ModuleGlobals:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.GlobalsTag.Id, text );
				}
				break;
				case TemplateModuleDataType.ModuleFunctions:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.FunctionsTag.Id, text );
				}
				break;
				case TemplateModuleDataType.ModulePragma:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.PragmaTag.Id, text );
				}
				break;
				case TemplateModuleDataType.ModulePass:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.PassTag.Id, text );
				}
				break;
				case TemplateModuleDataType.ModuleInputVert:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.InputsVertTag.Id, text );
				}
				break;
				case TemplateModuleDataType.ModuleInputFrag:
				{
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Modules.InputsFragTag.Id, text );
				}
				break;
			}
		}
		
		public void SetPropertyData( string[] properties )
		{
			string body = string.Empty;
			FillTemplateBody( -1, -1, TemplatesManager.TemplatePropertyTag, ref body, properties );
			SetPropertyData( body );
		}

		public void SetPropertyData( string text )
		{
			m_templateIdManager.SetReplacementText( m_propertyTag.Id, text );
		}

		public string GetSubShaderDataId( TemplateModuleDataType type, int subShaderId, bool addPrefix )
		{
			if ( subShaderId >= m_subShaders.Count )
				return string.Empty;

			string prefix = string.Empty;
			switch ( type )
			{
				case TemplateModuleDataType.ModuleBlendMode:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.BlendData.BlendModeId;
				}
				case TemplateModuleDataType.ModuleBlendOp:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.BlendData.BlendOpId;
				}
				case TemplateModuleDataType.ModuleCullMode:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.CullModeData.CullModeId;
				}
				case TemplateModuleDataType.ModuleColorMask:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.ColorMaskData.ColorMaskId;
				}
				case TemplateModuleDataType.ModuleStencil:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.StencilData.StencilBufferId;
				}
				case TemplateModuleDataType.ModuleZwrite:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.DepthData.ZWriteModeId;
				}
				case TemplateModuleDataType.ModuleZTest:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.DepthData.ZTestModeId;
				}
				case TemplateModuleDataType.ModuleZOffset:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.DepthData.OffsetId;
				}
				case TemplateModuleDataType.ModuleTag:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.TagData.TagsId;
				}
				case TemplateModuleDataType.ModuleGlobals:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.GlobalsTag.Id;
				}
				case TemplateModuleDataType.ModuleFunctions:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.FunctionsTag.Id;
				}
				case TemplateModuleDataType.ModulePragma:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.PragmaTag.Id;
				}
				case TemplateModuleDataType.ModulePass:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.PassTag.Id;
				}
				case TemplateModuleDataType.ModuleInputVert:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.InputsVertTag.Id;
				}
				case TemplateModuleDataType.ModuleInputFrag:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Modules.InputsFragTag.Id;
				}
			}
			return string.Empty;

		}
		public string GetPassDataId( TemplateModuleDataType type, int subShaderId, int passId, bool addPrefix )
		{
			if( subShaderId >= m_subShaders.Count || passId >= m_subShaders[ subShaderId ].Passes.Count )
				return string.Empty;

			string prefix = string.Empty;
			switch( type )
			{
				case TemplateModuleDataType.ModuleBlendMode:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.BlendData.BlendModeId;
				}
				case TemplateModuleDataType.ModuleBlendOp:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.BlendData.BlendOpId;
				}
				case TemplateModuleDataType.ModuleCullMode:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.CullModeData.CullModeId;
				}
				case TemplateModuleDataType.ModuleColorMask:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.ColorMaskData.ColorMaskId;
				}
				case TemplateModuleDataType.ModuleStencil:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.StencilData.StencilBufferId;
				}
				case TemplateModuleDataType.ModuleZwrite:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.DepthData.ZWriteModeId;
				}
				case TemplateModuleDataType.ModuleZTest:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.DepthData.ZTestModeId;
				}
				case TemplateModuleDataType.ModuleZOffset:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.DepthData.OffsetId;
				}
				case TemplateModuleDataType.ModuleTag:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.TagData.TagsId;
				}
				case TemplateModuleDataType.ModuleGlobals:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.GlobalsTag.Id;
				}
				case TemplateModuleDataType.ModuleFunctions:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.FunctionsTag.Id;
				}
				case TemplateModuleDataType.ModulePragma:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.PragmaTag.Id;
				}
				case TemplateModuleDataType.ModulePass:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.PassTag.Id;
				}
				case TemplateModuleDataType.ModuleInputVert:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.InputsVertTag.Id;
				}
				case TemplateModuleDataType.ModuleInputFrag:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.InputsFragTag.Id;
				}
				case TemplateModuleDataType.PassVertexFunction:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].UniquePrefix : string.Empty;
					return  prefix + m_subShaders[ subShaderId ].Passes[ passId ].VertexFunctionData.Id;
				}
				case TemplateModuleDataType.PassFragmentFunction:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].FragmentFunctionData.Id;
				}
				case TemplateModuleDataType.PassVertexData:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].UniquePrefix : string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].VertexDataContainer.VertexDataId;
				}
				case TemplateModuleDataType.PassInterpolatorData:
				{
					prefix = addPrefix ? m_subShaders[ subShaderId ].Passes[ passId ].UniquePrefix: string.Empty;
					return prefix + m_subShaders[ subShaderId ].Passes[ passId ].InterpolatorDataContainer.InterpDataId;
				}
			}
			return string.Empty;
		}

		public void SetPassData( TemplateModuleDataType type, int subShaderId, int passId, string[] list )
		{
			//if( list == null || list.Length == 0 )
			//	return;

			string id = GetPassDataId( type, subShaderId, passId ,false);
			string body = string.Empty;
			FillTemplateBody( subShaderId, passId, id, ref body, list );
			SetPassData( type, subShaderId, passId, body );
		}

		public void SetPassData( TemplateModuleDataType type, int subShaderId, int passId, List<PropertyDataCollector> list )
		{
			//if( list == null || list.Count == 0 )
			//	return;

			string id = GetPassDataId( type, subShaderId, passId, false);
			string body = string.Empty;
			FillTemplateBody( subShaderId, passId, id, ref body, list );
			SetPassData( type, subShaderId, passId, body );
		}

		public void SetPassData( TemplateModuleDataType type, int subShaderId, int passId, string text )
		{
			if( subShaderId >= m_subShaders.Count || passId >= m_subShaders[ subShaderId ].Passes.Count )
				return;

			string prefix = string.Empty;
			switch( type )
			{
				case TemplateModuleDataType.ModuleShaderModel:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.ShaderModel.Id, text );
				}
				break;
				case TemplateModuleDataType.ModuleBlendMode:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.BlendData.BlendModeId, text );
				}
				break;
				case TemplateModuleDataType.ModuleBlendOp:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.BlendData.BlendOpId, text );
				}
				break;
				case TemplateModuleDataType.ModuleCullMode:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.CullModeData.CullModeId, text );
				}
				break;
				case TemplateModuleDataType.ModuleColorMask:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.ColorMaskData.ColorMaskId, text );
				}
				break;
				case TemplateModuleDataType.ModuleStencil:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.StencilData.StencilBufferId, text );
				}
				break;
				case TemplateModuleDataType.ModuleZwrite:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.DepthData.ZWriteModeId, text );
				}
				break;
				case TemplateModuleDataType.ModuleZTest:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.DepthData.ZTestModeId, text );
				}
				break;
				case TemplateModuleDataType.ModuleZOffset:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.DepthData.OffsetId, text );
				}
				break;
				case TemplateModuleDataType.ModuleTag:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.TagData.TagsId, text );
				}
				break;
				case TemplateModuleDataType.ModuleGlobals:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.GlobalsTag.Id, text );
				}
				break;
				case TemplateModuleDataType.ModuleFunctions:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.FunctionsTag.Id, text );
				}
				break;
				case TemplateModuleDataType.ModulePragma:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.PragmaTag.Id, text );
				}
				break;
				case TemplateModuleDataType.ModulePass:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.PassTag.Id, text );
				}
				break;
				case TemplateModuleDataType.ModuleInputVert:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.InputsVertTag.Id, text );
				}
				break;
				case TemplateModuleDataType.ModuleInputFrag:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].Modules.UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].Modules.InputsFragTag.Id, text );
				}
				break;
				case TemplateModuleDataType.PassVertexFunction:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].VertexFunctionData.Id, text );
				}
				break;
				case TemplateModuleDataType.PassFragmentFunction:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].FragmentFunctionData.Id, text );
				}
				break;
				case TemplateModuleDataType.PassVertexData:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].VertexDataContainer.VertexDataId, text );
				}
				break;
				case TemplateModuleDataType.PassInterpolatorData:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].InterpolatorDataContainer.InterpDataId, text );
				}
				break;
				case TemplateModuleDataType.PassNameData:
				{
					prefix = m_subShaders[ subShaderId ].Passes[ passId ].UniquePrefix;
					m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].PassNameContainer.Id, text );
				}
				break;
			}
		}

		public void SetPassInputData( int subShaderId, int passId, int inputId, string text )
		{
			if( subShaderId >= m_subShaders.Count ||
				passId >= m_subShaders[ subShaderId ].Passes.Count ||
				inputId >= m_subShaders[ subShaderId ].Passes[ passId ].InputDataList.Count )
				return;

			string prefix = m_subShaders[ subShaderId ].Passes[ passId ].UniquePrefix;
			m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].InputDataFromId( inputId ).TagId, text );
		}

		public void SetPassInputDataByArrayIdx( int subShaderId, int passId, int inputId, string text )
		{
			if( subShaderId >= m_subShaders.Count ||
				passId >= m_subShaders[ subShaderId ].Passes.Count ||
				inputId >= m_subShaders[ subShaderId ].Passes[ passId ].InputDataList.Count )
				return;

			string prefix = m_subShaders[ subShaderId ].Passes[ passId ].UniquePrefix;
			m_templateIdManager.SetReplacementText( prefix + m_subShaders[ subShaderId ].Passes[ passId ].InputDataList[ inputId ].TagId, text );
		}

		public TemplateData CreateTemplateData( string name, string guid, int subShaderId, int passId )
		{
			if( subShaderId >= m_subShaders.Count ||
				passId >= m_subShaders[ subShaderId ].Passes.Count )
				return null;

			if( string.IsNullOrEmpty( name ) )
				name = m_defaultShaderName;

			TemplateData templateData = new TemplateData( name );
			templateData.GUID = guid;
			templateData.TemplateBody = m_shaderBody;
			templateData.DefaultShaderName = m_defaultShaderName;
			templateData.ShaderNameId = m_shaderNameId;
			templateData.OrderId = m_orderId;

			templateData.InputDataList = SubShaders[ subShaderId ].Passes[ passId ].InputDataList;
			templateData.VertexDataContainer = SubShaders[ subShaderId ].Passes[ passId ].VertexDataContainer;
			templateData.InterpolatorDataContainer = SubShaders[ subShaderId ].Passes[ passId ].InterpolatorDataContainer;
			templateData.AvailableShaderProperties = m_availableShaderProperties;
			templateData.VertexFunctionData = SubShaders[ subShaderId ].Passes[ passId ].VertexFunctionData;
			templateData.FragmentFunctionData = SubShaders[ subShaderId ].Passes[ passId ].FragmentFunctionData;
			templateData.BlendData = SubShaders[ subShaderId ].Passes[ passId ].Modules.BlendData;
			templateData.CullModeData = SubShaders[ subShaderId ].Passes[ passId ].Modules.CullModeData;
			templateData.ColorMaskData = SubShaders[ subShaderId ].Passes[ passId ].Modules.ColorMaskData;
			templateData.StencilData = SubShaders[ subShaderId ].Passes[ passId ].Modules.StencilData;
			templateData.DepthData = SubShaders[ subShaderId ].Passes[ passId ].Modules.DepthData;
			templateData.TagData = SubShaders[ subShaderId ].Passes[ passId ].Modules.TagData;

			//templateData.PropertyList = m_pr;
			//private Dictionary<string, TemplateProperty> m_propertyDict = new Dictionary<string, TemplateProperty>();

			return templateData;
		}

		public bool FillTemplateBody( int subShaderId, int passId, string id, ref string body, List<PropertyDataCollector> values )
		{
			if( values.Count == 0 )
			{
				return true;
			}

			string[] array = new string[ values.Count ];
			for( int i = 0; i < values.Count; i++ )
			{
				array[ i ] = values[ i ].PropertyName;
			}
			return FillTemplateBody( subShaderId, passId, id, ref body, array );
		}

		public bool FillTemplateBody( int subShaderId, int passId, string id, ref string body, params string[] values )
		{
			if( values.Length == 0 )
			{
				if( id[ id.Length - 1] == '\n' )
					body = "\n";

				return true;
			}

			TemplatePropertyContainer propertyContainer = null;
			if( subShaderId >= 0 )
			{
				if( passId >= 0 )
				{
					propertyContainer = SubShaders[ subShaderId ].Passes[ passId ].TemplateProperties;
				}
				else
				{
					propertyContainer = SubShaders[ subShaderId ].TemplateProperties;
				}
			}
			else
			{
				propertyContainer = m_templateProperties;
			}

			propertyContainer.BuildInfo();

			if( propertyContainer.PropertyDict.ContainsKey( id ) )
			{
				string finalValue = propertyContainer.PropertyDict[ id ].UseIndentationAtStart? propertyContainer.PropertyDict[ id ].Indentation:string.Empty;
				for( int i = 0; i < values.Length; i++ )
				{

					if( propertyContainer.PropertyDict[ id ].AutoLineFeed )
					{
						string[] valuesArr = values[ i ].Split( '\n' );
						for( int j = 0; j < valuesArr.Length; j++ )
						{
							//first value will be automatically indented by the string replace
							finalValue += ( ( i == 0 && j == 0 ) ? string.Empty : propertyContainer.PropertyDict[ id ].Indentation ) + valuesArr[ j ];
							finalValue += TemplatesManager.TemplateNewLine;
						}

					}
					else
					{
						//first value will be automatically indented by the string replace
						finalValue += ( i == 0 ? string.Empty : propertyContainer.PropertyDict[ id ].Indentation ) + values[ i ];
					}
				}

				body = finalValue;
				propertyContainer.PropertyDict[ id ].Used = true;
				return true;
			}

			if( values.Length > 1 || !string.IsNullOrEmpty( values[ 0 ] ) )
			{
				UIUtils.ShowMessage( string.Format( "Attempting to write data into inexistant tag {0}. Please review the template {1} body and consider adding the missing tag.", id, m_defaultShaderName ), MessageSeverity.Error );
				return false;
			}
			return true;
		}

		public bool FillVertexInstructions( int subShaderId, int passId, params string[] values )
		{
			TemplateFunctionData vertexFunctionData = SubShaders[ subShaderId ].Passes[ passId ].VertexFunctionData;
			if( vertexFunctionData != null && !string.IsNullOrEmpty( vertexFunctionData.Id ) )
			{
				string body = string.Empty;
				bool isValid = FillTemplateBody( subShaderId, passId, vertexFunctionData.Id, ref body, values );
				SetPassData( TemplateModuleDataType.PassVertexFunction, subShaderId, passId, body );
				return isValid;
			}

			if( values.Length > 0 )
			{
				UIUtils.ShowMessage( "Attemping to add vertex instructions on a template with no assigned vertex code area", MessageSeverity.Error );
				return false;
			}
			return true;
		}

		public bool FillFragmentInstructions( int subShaderId, int passId, params string[] values )
		{
			TemplateFunctionData fragmentFunctionData = SubShaders[ subShaderId ].Passes[ passId ].VertexFunctionData;
			if( fragmentFunctionData != null && !string.IsNullOrEmpty( fragmentFunctionData.Id ) )
			{
				string body = string.Empty;
				bool isValid = FillTemplateBody( subShaderId, passId, fragmentFunctionData.Id, ref body, values );
				SetPassData( TemplateModuleDataType.PassFragmentFunction, subShaderId, passId, body );
				return isValid;
			}

			if( values.Length > 0 )
			{
				UIUtils.ShowMessage( "Attemping to add fragment instructions on a template with no assigned vertex code area", MessageSeverity.Error );
				return false;
			}
			return true;
		}

		public void SetShaderName( string name )
		{
			m_templateIdManager.SetReplacementText( m_shaderNameId, name );
		}

		public override void Reload()
		{
			m_availableShaderProperties.Clear();
			int count = m_subShaders.Count;
			for( int i = 0; i < count; i++ )
			{
				m_subShaders[ i ].Destroy();
			}
			m_subShaders.Clear();

			m_templateIdManager.Reset();
			if( m_shaderData != null ) 
				m_shaderData.Destroy();

			m_templateProperties.Reset();

			LoadTemplateBody( m_guid );
		}

		public List<TemplateSubShader> SubShaders { get { return m_subShaders; } }
		public List<TemplateShaderPropertyData> AvailableShaderProperties { get { return m_availableShaderProperties; } }
		public TemplateTagData PropertyTag { get { return m_propertyTag; } }
		public TemplateIdManager IdManager { get { return m_templateIdManager; } }
		public TemplatePropertyContainer TemplateProperties { get { return m_templateProperties; } }
		public bool IsSinglePass { get { return m_isSinglePass; } }
		public int MasterNodesRequired { get { return m_masterNodesRequired; } }
	}
}
