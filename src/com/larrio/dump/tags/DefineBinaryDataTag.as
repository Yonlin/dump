
package com.larrio.dump.tags
{
	import com.larrio.dump.codec.FileDecoder;
	import com.larrio.dump.codec.FileEncoder;
	import com.larrio.dump.utils.assertTrue;
	
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @author larryhou
	 * @createTime Dec 24, 2012 12:41:37 AM
	 */
	public class DefineBinaryDataTag extends SWFTag
	{
		public static const TYPE:uint = TagType.DEFINE_BINARY_DATA;
		
		private var _data:ByteArray;
		
		/**
		 * 构造函数
		 * create a [DefineBinaryDataTag] object
		 */
		public function DefineBinaryDataTag()
		{
			
		}
		
		/**
		 * 二进制解码 
		 * @param decoder	解码器
		 */		
		override protected function decodeTag(decoder:FileDecoder):void
		{
			_character = decoder.readUI16();
			_dict[_character] = this;
			
			assertTrue(decoder.readUI32() == 0);
			
			_data = new ByteArray();
			decoder.readBytes(_data);
		}
		
		/**
		 * 二进制编码 
		 * @param encoder	编码器
		 */		
		override protected function encodeTag(encoder:FileEncoder):void
		{
			encoder.writeUI16(_character);
			encoder.writeUI32(0);
			
			encoder.writeBytes(_data);
		}
		
		/**
		 * 字符串输出
		 */		
		public function toString():String
		{
			var result:XML = new XML("<DefineBinaryDataTag/>");
			result.@charactor = _character;
			result.@size = _data.length;
			return result.toXMLString();	
		}

		/**
		 * 二进制数据
		 */		
		public function get data():ByteArray { return _data; }
		public function set data(value:ByteArray):void
		{
			_data = value;
		}
		
	}
}