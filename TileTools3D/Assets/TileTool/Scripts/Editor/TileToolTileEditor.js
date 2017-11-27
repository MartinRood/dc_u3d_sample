/*
http://www.cgsoso.com/forum-211-1.html

CG搜搜 Unity3d 每日Unity3d插件免费更新 更有VIP资源！

CGSOSO 主打游戏开发，影视设计等CG资源素材。

插件如若商用，请务必官网购买！

daily assets update for try.

U should buy the asset from home store if u use it in your project!
*/

@CustomEditor(TileToolTile)
public class TileToolTileEditor extends Editor {	
	var tex: Texture = null;
	function Awake()
	{
		tex = Resources.Load("TT_SideHelp");	
	}
	function OnEnable(){
		target.FindAndSetTileValues();
		var TTS:TileToolStyle = target.gameObject.GetComponent(TileToolStyle);
		if(!TTS){
			target.gameObject.AddComponent(TileToolStyle);
		}
		if (GUI.changed){
			EditorUtility.SetDirty(target);
		}
	}					
    override function OnInspectorGUI () {
    	DrawDefaultInspector();	
		var titleStyle = new GUIStyle(GUI.skin.label);
		GUILayout.Label(tex, titleStyle);
	}	
}
