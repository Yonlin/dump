package com.larrio.dump.tags
{
	import com.larrio.dump.codec.FileDecoder;
	import com.larrio.dump.codec.FileEncoder;
	import com.larrio.dump.utils.assertTrue;
	import com.larrio.dump.utils.hexSTR;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * TAG抽象类
	 * @author larryhou
	 * @createTime Dec 15, 2012 6:36:43 PM
	 */
	public class SWFTag
	{
		protected var _dict:Dictionary;
		
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
			const NAME:String = "TYPE";
			if (NAME in Object(this).constructor)
			{
				_type = Object(this).constructor[NAME];
			}
		}
		
		/**
		 * 对二进制进行解码 
		 * @param codec	编解码数据
		 */		
		public function decode(decoder:FileDecoder):void
		{
			readTagHeader(decoder);
			
			assertTrue(_length >= 0, "TAG[0x" + _type.toString(16).toUpperCase() + "]长度不合法：" + _length);
			
			_bytes = new ByteArray();
			if (_length > 0) 
			{
				decoder.readBytes(_bytes, 0, _length);
			}
			
			decoder = new FileDecoder();
			decoder.writeBytes(_bytes);
			decoder.position = 0;
			
			decodeTag(decoder);
			
			var remain:uint;
			if (decoder.position > 0)
			{
				remain = decoder.bytesAvailable;
			}
			
			if (remain > 0)
			{
				var warning:String = getQualifiedClassName(this).split("::")[1];
				if (_character) warning += "@" + _character;
				
				trace("#" + warning + "# " + remain + " UNRESOLVED BYTES:");
				trace(hexSTR(decoder, 4, decoder.position, remain));
			}
			
			const NAME:String = "TYPE";
			if (NAME in Object(this).constructor)
			{
				assertTrue(_type == Object(this).constructor[NAME]);
			}
		}
		
		/**
		 * 对二进制进行编码
		 * @param codec	编解码数据
		 */		
		public function encode(encoder:FileEncoder):void
		{
			var data:FileEncoder;
			
			data = new FileEncoder();
			encodeTag(data);
			data.flush();
			
			_length = data.length;
			
			writeTagHeader(encoder);
			encoder.writeBytes(data);
		}
		
		/**
		 * 写入TAG头信息 
		 * @param encoder	编码器
		 */		
		protected final function writeTagHeader(encoder:FileEncoder):void
		{
			if (_length < 0x3F)
			{
				encoder.writeUI16(_type << 6 | _length);
			}
			else
			{
				encoder.writeUI16(_type << 6 | 0x3F);
				encoder.writeS32(_length);
			}
		}
		
		/**
		 * 读取TAG头信息 
		 * @param decoder	解码器
		 */		
		protected final function readTagHeader(decoder:FileDecoder):void
		{
			var codeAndLength:uint = decoder.readUI16();
			
			_type = codeAndLength >>> 6;
			_length = codeAndLength & 0x3F;
			
			if (_length >= 0x3F)
			{
				_length = decoder.readS32();
			}
		}

		
		/**
		 * 对TAG内容进行二进制编码
		 * @param encoder	编码器
		 */		
		protected function encodeTag(encoder:FileEncoder):void
		{
			_bytes && encoder.writeBytes(_bytes);
		}
		
		/**
		 * 对TAG二进制内容进行解码 
		 * @param decoder	解码器
		 */		
		protected function decodeTag(decoder:FileDecoder):void
		{
			if (DefineTagType.isDefineTag(_type))
			{
				_character = decoder.readUI16();
				_dict[_character] = this;
				
				decoder.position -= 2;
			}
		}
		
		/**
		 * TAG类型
		 */		
		public function get type():uint { return _type; }

		/**
		 * TAG字节数组
		 */		
		public function get bytes():ByteArray { return _bytes; }
		public function set bytes(value:ByteArray):void
		{
			_bytes = value;
		}

		/**
		 * 特征ID
		 */		
		public function get character():uint { return _character; }
		public function set character(value:uint):void
		{
			// 针对不解析TAG内容时修改character值的情况下做兼容性优化
			if (getQualifiedClassName(this) == getQualifiedClassName(SWFTag) && _bytes)
			{
				var encoder:ByteArray = new ByteArray();
				encoder.writeByte((value >>> 0) & 0xFF);
				encoder.writeByte((value >>> 8) & 0xFF);
				
				_bytes[0] = encoder[0];
				_bytes[1] = encoder[1];
			}
			
			_character = value;
		}

		/**
		 * 映射表
		 */		
		public function get dict():Dictionary { return _dict; }
		public function set dict(value:Dictionary):void
		{
			_dict = value;
		}
	}
}