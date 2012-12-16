package com.larrio.utils
{
	import flash.utils.ByteArray;
	
	/**
	 * 打印二进制数据
	 * @author larryhou
	 * @createTime Dec 16, 2012 10:52:32 PM
	 */
	public function printBytes(bytes:ByteArray, column:uint = 4):void
	{
		var hash:Array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"];
		
		var result:String = "";
		var left:String = "", right:String = "";
		
		var byte:uint;
		var count:int = 0;
		while (bytes.bytesAvailable)
		{
			byte = bytes[bytes.position++];
			
			left += hash[byte >>> 4] + hash[byte & 0xF] + " ";
			right += (byte >= 33 && byte < 127)? String.fromCharCode(byte) : "?";
			
			count++;
			if (count % 4 == 0) left += " ";
			if (count % (column * 4) == 0) 
			{
				result += left + right + "\r\n";
				left = right = "";
			}
		}
		
		var length:uint;
		if (left.length > 0)
		{
			length = column * 13;
			while (left.length < length) left += " ";
			result += left + right;
		}
		
		trace(result);
	}
}