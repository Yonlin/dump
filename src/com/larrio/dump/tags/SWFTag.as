package com.larrio.dump.tags
{
	import com.larrio.utils.FileDecoder;
	import com.larrio.utils.FileEncoder;
	import com.larrio.utils.assertTrue;
	
	import flash.utils.ByteArray;
	
	/**
	 * TAG抽象类
	 * @author larryhou
	 * @createTime Dec 15, 2012 6:36:43 PM
	 */
	public class SWFTag
	{
		protected var _type:uint;
		protected var _character:uint;
		
		protected var _length:int;
		protected var _bytes:ByteArray;
		
		/**
		 * 构造函数
		 * create a [SWFTag] object
		 */
		public function SWFTag()
		{
			
		}
		
		/**
		 * 对二进制进行解码 
		 * @param codec	编解码数据
		 */		
		public function decode(decoder:FileDecoder):void
		{
			var codeAndLength:uint = decoder.readUI16();
			
			_type = codeAndLength >>> 6;
			_length = codeAndLength & 0x3F;
			
			if (_length == 0x3F)
			{
				_length = decoder.readS32();
			}
			
			assertTrue(_length >= 0, "TAG[0x" + _type.toString(16).toUpperCase() + "]长度不合法：" + _length);
			
			_bytes = new ByteArray();
			if (_length == 0) return;
			
			decoder.readBytes(_bytes, 0, _length);
			
			assertTrue(_bytes.length == _length);
		}
		
		/**
		 * 对二进制进行编码
		 * @param codec	编解码数据
		 */		
		public function encode(encoder:FileEncoder):void
		{
			
		}

		/**
		 * TAG类型
		 */		
		public function get type():uint { return _type; }

		/**
		 * TAG字节数组
		 */		
		public function get bytes():ByteArray { return _bytes; }
	}
}