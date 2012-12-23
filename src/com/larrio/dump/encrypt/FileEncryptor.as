package com.larrio.dump.encrypt
{
	import com.larrio.dump.SWFile;
	import com.larrio.dump.doabc.ClassInfo;
	import com.larrio.dump.doabc.MultiKindType;
	import com.larrio.dump.doabc.MultinameInfo;
	import com.larrio.dump.doabc.ScriptInfo;
	import com.larrio.dump.doabc.TraitInfo;
	import com.larrio.dump.tags.DoABCTag;
	import com.larrio.dump.tags.SWFTag;
	import com.larrio.dump.tags.SymbolClassTag;
	import com.larrio.dump.tags.TagType;
	import com.larrio.dump.utils.assertTrue;
	
	import flash.utils.Dictionary;
	
	/**
	 * SWF代码加密器
	 * @author larryhou
	 * @createTime Dec 22, 2012 8:19:10 PM
	 */
	public class FileEncryptor
	{
		private var _files:Vector.<SWFile>;
		private var _queue:Vector.<EncryptItem>;
		
		private var _names:Vector.<String>;
		
		private var _map:Dictionary;
		private var _reverse:Dictionary;
		
		/**
		 * 构造函数
		 * create a [FileEncryptor] object
		 */
		public function FileEncryptor()
		{
			_files = new Vector.<SWFile>;
			
			_names = new Vector.<String>;
			_queue = new Vector.<EncryptItem>;
			
			_map = new Dictionary(true);
			_reverse = new Dictionary(true);
		}
		
		/**
		 * 文件添加完成后调用此方法进行加密处理 
		 */		
		public function encrypt():void
		{
			var item:EncryptItem;
			var length:uint, i:int;
			
			var key:String;
			var value:String, index:uint;
			
			for each(item in _queue)
			{
				length = item.classes.length;
				for (i = 0; i < length; i++)
				{
					index = item.classes[i];
					value = item.strings[index];
					
					if (_reverse[value]) continue;
					if (_map[value])
					{
						item.strings[index] = _map[value];
						continue;
					}
					
					while(true)
					{
						key = createEncryptSTR(value);
						if (!_reverse[key]) break;
					}
					
					_map[value] = key;
					_reverse[key] = value;
					
					_names.push(value);
					
					item.strings[index] = key;
				}
			}
			
			// 按照字符串从长到短排列
			_names.sort(function(s1:String, s2:String):int
			{
				return s1.length > s2.length? -1 : 1;
			});
			
			
			var name:String;
			for each(item in _queue)
			{
				replace(item.strings, 1);
			}
			
			var symbol:SymbolClassTag;
			for (i = 0; i < _files.length; i++)
			{
				symbol = _files[i].symbol;
				if (!symbol) continue;
				
				replace(symbol.symbols);
			}
			
		}
		
		// 替换加密串
		private function replace(strings:Vector.<String>, offset:uint = 0):void
		{
			var value:String, key:String;
			var length:int = strings.length;
			for(var i:int = offset; i < length; i++)
			{
				value = strings[i];
				for (var k:int = 0; k < _names.length; k++)
				{
					key = _names[k];
					if (value.indexOf(key) >= 0)
					{
						while (value.indexOf(key) >= 0)
						{
							value = value.replace(key, _map[key]);
						}
						
						strings[i] = value;
						break;
					}
				}
			}
		}
		
		// 获取加密字符串
		private function createEncryptSTR(source:String):String
		{
			var result:String = "";
			
			var min:uint, max:uint;
			min = 33; max = 126;
			
			while (result.length < source.length)
			{
				result += String.fromCharCode(min + (max - min) * Math.random() >> 0);
			}
			
			assertTrue(result.length == source.length);
			
			return result;
		}
		
		/**
		 * 加密文件
		 * @param swf	SWFile对象
		 */		
		public function addFile(swf:SWFile):void
		{
			_files.push(swf);
			
			var symbol:SymbolClassTag;
			var list:Vector.<DoABCTag> = new Vector.<DoABCTag>();
			for each(var tag:SWFTag in swf.tags)
			{
				if (tag.type == TagType.DO_ABC) 
				{
					list.push(tag as DoABCTag);
				}
				else
				if (tag.type == TagType.SYMBOL_CLASS)
				{
					symbol = tag as SymbolClassTag;
				}
			}
			
			processABCTags(list, symbol);
		}
		
		/**
		 * 批量处理ABC 
		 * @param list	DoABCTag对象数组
		 */		
		private function processABCTags(list:Vector.<DoABCTag>, symbol:SymbolClassTag):void
		{
			var tag:DoABCTag;
			var item:EncryptItem;
			
			for each(tag in list)
			{
				_queue.push(item = new EncryptItem(tag, symbol));
				
				for each(var script:ScriptInfo in tag.abc.scripts)
				{
					for each(var trait:TraitInfo in script.classes)
					{
						var cls:ClassInfo = tag.abc.classes[trait.data.classi];
						var multiname:MultinameInfo = tag.abc.constants.multinames[cls.instance.name];
						switch (multiname.kind)
						{
							case MultiKindType.QNAME:
							case MultiKindType.QNAME_A:
							{
								item.packages.push(tag.abc.constants.namespaces[multiname.ns].name);
								item.classes.push(multiname.name);
								break;
							}
						}
					}
				}
			}
		}
	}
}