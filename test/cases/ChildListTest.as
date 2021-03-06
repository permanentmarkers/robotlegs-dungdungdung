package cases
{	
	import dung.dung.dung.core.NodeMap;
	import dung.dung.dung.interfaces.INodeMap;
	import data.childlistdata;
	import dung.dung.dung.core.ChildList;
	import dung.dung.dung.interfaces.IChildList;
	import org.flexunit.Assert;
	import mocks.ViewMock1;
	import org.swiftsuspenders.Injector;
	import mocks.VOMock1;
	import mocks.ViewMock2;
	import data.childlistoverridedata;
	import mocks.ViewMock3;
	
	public class ChildListTest
	{
		private var injector:Injector;
		private var nodeMap:NodeMap;
		
		private function mapItems(data:XMLList):ChildList
		{
			injector.mapClass(ViewMock1, ViewMock1);
			nodeMap.mapPath('item', ViewMock1, VOMock1);
			nodeMap.mapPath('item.children.message', ViewMock2);
			Assert.assertEquals('4 item nodes should be in the xml', 4, childlistdata.item.length());
			
			var childList:ChildList = new ChildList(data);
			injector.injectInto(childList);
			return childList;
		}
		
		[Before]
		public function runBeforeEachTest():void
		{
			injector = new Injector;
			nodeMap = new NodeMap();
			injector.mapValue(Injector, injector);
			injector.mapValue(INodeMap, nodeMap);
			injector.mapClass(ViewMock2, ViewMock2);
			injector.mapClass(IChildList, ChildList);
			injector.mapValue(String, 'children', ChildList.CHILDLIST_NODE_NAME);
		}
		
		[Test]
		public function canCreateChildNode():void
		{
			var childList:ChildList = new ChildList(childlistdata.item);
			injector.injectInto(childList);
			Assert.assertTrue('injector was set', childList.injector);
			Assert.assertTrue('nodemap was set', childList.nodeMap);
		}
		
		[Test]
		public function canEvaluateChildList():void
		{
			var childList:ChildList = mapItems(childlistdata.item);
			var objects:Array = childList.children();
			Assert.assertEquals('4 children should be created', 4, objects.length);
		}
		
		[Test]
		public function childListAreInjectedWhenANodeHasChildren():void
		{
			var childList:ChildList = mapItems(childlistdata.item);
			var objects:Array = childList.children();
			for each (var item:ViewMock1 in objects) {
				Assert.assertEquals('each item has 3 child nodes', 3, item.childList.children().length);
			}
		}
		
		[Test]
		public function valueObjectArePopulated():void
		{
			var objects:ChildList = mapItems(childlistdata.item);
			for each (var item:ViewMock1 in objects.childrenOfType(ViewMock1)) {
				Assert.assertTrue(int(Number(item.dataProvider.ammount)) > 3);
				Assert.assertTrue(int(Number(item.dataProvider.ammount)) < 41);
				Assert.assertTrue(item.dataProvider.tax.lastIndexOf('%') != -1);
			}
		}
		
		[Test]
		public function overrideDoesNotClash():void
		{
			var objects:ChildList = mapItems(childlistoverridedata.item);
			for each (var item:ViewMock1 in objects.childrenOfType(ViewMock1)) {
				// in ViewMock1 we have mapped ViewMock2 to ViewMock3 only if ammount == 9
				if (item.dataProvider.ammount == '9') {
					Assert.assertTrue('The messages should be ViewMock3 instead of ViewMock2', item.getChildAt(0) is ViewMock3)
				} else {
					Assert.assertTrue('The messages should be ViewMock2', item.getChildAt(0) is ViewMock2)
				}
				
			}
		}
		
	}
}