package com.larrio.dump.doabc
{
	import com.larrio.dump.codec.FileDecoder;
	import com.larrio.dump.codec.FileEncoder;
	import com.larrio.dump.interfaces.ICodec;
	import com.larrio.dump.interfaces.IScript;
	
	import flash.utils.Dictionary;
	
	/**
	 * DoABC之代码信息
	 * @author larryhou
	 * @createTime Dec 16, 2012 3:43:37 PM
	 */
	public class ScriptInfo implements ICodec, IScript
	{
		private var _initializer:uint;
		
		private var _traits:Vector.<TraitInfo>;
		private var _map:Dictionary;
		
		private var _variables:Vector.<TraitInfo>;
		private var _methods:Vector.<TraitInfo>;
		private var _classes:Vector.<TraitInfo>;
		
		
		private var _abc:DoABC;
		
		private var _belong:IScript;
		
		/**
		 * 构造函数
		 * create a [ScriptInfo] object
		 */
		public function ScriptInfo(abc:DoABC)
		{
			_abc = abc;
		}
		
		/**
		 * 二进制解码 
		 * @param decoder	解码器
		 */		
		public function decode(decoder:FileDecoder):void
		{
			_initializer = decoder.readEU30();
			
			_abc.methods[_initializer].type = MethodType.INITIALIZER;
			_abc.methods[_initializer].belong = this;
			
			_map = new Dictionary();
			
			var _lenght:uint, i:int;
			
			_lenght = decoder.readEU30();
			_traits = new Vector.<TraitInfo>(_lenght, true);
			for (i = 0; i < _lenght; i++)
			{
				_traits[i] = new TraitInfo(_abc);
				_traits[i].decode(decoder);
				
				_map[_traits[i].data.id] = _traits[i];
				
				// 特征归类
				switch (_traits[i].kind & 0xF)
				{
					case TraitType.GETTER:
					case TraitType.SETTER:
					case TraitType.METHOD:
					case TraitType.FUNCTION:
					{
						if (!_methods) _methods = new Vector.<TraitInfo>;
						_methods.push(_traits[i]);
						break;
					}
						
					case TraitType.CLASS:
					{
						if (!_classes) _classes = new Vector.<TraitInfo>;
						_classes.push(_traits[i]);
						
						_abc.classes[_traits[i].data.classi].belong = this;
						break;
					}
						
					default:
					{
						if (!_variables) _variables = new Vector.<TraitInfo>;
						_variables.push(_traits[i]);
						break;
					}
				}
				
			}
		}
		
		/**
		 * 二进制编码 
		 * @param encoder	编码器
		 */		
		public function encode(encoder:FileEncoder):void
		{
			var length:uint, i:int;
			
			encoder.writeEU30(_initializer);
			
			length = _traits.length;
			encoder.writeEU30(length);
			
			for (i = 0; i < length; i++)
			{
				_traits[i].encode(encoder);
			}
		}
		
		public function getTrait(id:uint):TraitInfo
		{
			return _map[id] as TraitInfo;
		}
		
		/**
		 * 字符串输出
		 */		
		public function toString():String
		{
			return "script:[Trait]" + _traits.join("\n       [Trait]");
		}	
		
		/**
		 * 指向methods数组的索引
		 * static initializer for class
		 */		
		public function get initializer():uint { return _initializer; }
		
		/**
		 * 特征信息
		 */		
		public function get traits():Vector.<TraitInfo> { return _traits; }
		
		/**
		 * 全局变量特征信息
		 */		
		public function get variables():Vector.<TraitInfo> { return _variables; }
		
		/**
		 * 方法特征信息
		 */		
		public function get methods():Vector.<TraitInfo> { return _methods; }
		
		/**
		 * 类特征信息
		 */		
		public function get classes():Vector.<TraitInfo> { return _classes; }

		/**
		 * 对象所属容器
		 */		
		public function get belong():IScript { return _belong; }
		public function set belong(value:IScript):void
		{
			_belong = value;
		}

	}
}