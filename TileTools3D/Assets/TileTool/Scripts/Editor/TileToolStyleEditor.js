/*
http://www.cgsoso.com/forum-211-1.html

CG搜搜 Unity3d 每日Unity3d插件免费更新 更有VIP资源！

CGSOSO 主打游戏开发，影视设计等CG资源素材。

插件如若商用，请务必官网购买！

daily assets update for try.

U should buy the asset from home store if u use it in your project!
*/

@CustomEditor(TileToolStyle)
@CanEditMultipleObjects
public class TileToolStyleEditor extends Editor {
	function OnEnable(){	
		FindAndSetTileValues();
		if (GUI.changed){
			EditorUtility.SetDirty(target);
		}
	}	
    override function OnInspectorGUI () {
    	DrawDefaultInspector();
	}
	function FindAndSetTileValues(){
	// Fills in values that are missing, only happens in editor
		if(target.style == "" || target.objectName == ""){
			var words = target.gameObject.name.Split("_" [0]);
			target.style = words[0];
			target.objectName = target.gameObject.name.Replace(target.style, "");
		}
	}
}
