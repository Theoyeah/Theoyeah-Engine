


class MoreArray /*extends Array *///wtf i dont know
	{
		public function deleteItemsExcept(array:Array, ?except:Int = 1):Void { //can someone please prove it for me?
			for (i in 0...array.length-except) {
				array.pop();
			}
		}
	}
