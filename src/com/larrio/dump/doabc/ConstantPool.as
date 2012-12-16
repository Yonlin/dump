package com.larrio.dump.doabc
{
	import com.larrio.dump.interfaces.ICodec;
	import com.larrio.utils.FileDecoder;
	import com.larrio.utils.FileEncoder;
	
	/**
	 * DoABC常量集合
	 * @author larryhou
	 * @createTime Dec 16, 2012 3:11:50 PM
	 */
	public class ConstantPool implements ICodec
	{
		private var _ints:Vector.<int>;
		private var _uints:Vector.<uint>;
		private var _doubles:Vector.<Number>;
		private var _strings:Vector.<String>;
		
		private var _nssets:Vector.<NamespaceSetInfo>;
		private var _namespaces:Vector.<NamespaceInfo>;
		
		private var _multinames:Vector.<MultinameInfo>;
		
		/**
		 * 构造函数
		 * create a [ConstantPool] object
		 */
		public function ConstantPool()
		{
			
		}
		
		/**
		 * 二进制解码 
		 * @param decoder	解码器
		 */		
		public function decode(decoder:FileDecoder):void
		{
			
		}
		
		/**
		 * 二进制编码 
		 * @param encoder	编码器
		 */		
		public function encode(encoder:FileEncoder):void
		{
			
		}
	}
}