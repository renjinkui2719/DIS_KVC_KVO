# DIS_KVC_KVO
根据IOS Foundation框架汇编反写的KVC,KVO实现，可以在mac, IOS环境下运行调试, KVC与KVO实现机制密不可分，所以将它们作为一个工程。  

主要用作学习与研究，加深对KVC,KVO机制的理解，理解oc runtime在这些机制实现中的重要作用.  

为了在xcode里正确编译调试,工程代码命名遵循一个规则:  
和系统冲突的地方全部用D或者d_前缀修饰. 比如: 

Category `NSObject+NSKeyValueCoding`, 在工程实现中改名为`NSObject+DSKeyValueCoding`  
同理:  
方法 `- (id)valueForKey:(NSString *)key` ==> `- (id)d_valueForKey:(NSString *)key` 

方法 `- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context` ==> `- (void)d_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context`
  
...  

类`NSKeyValueObservance` ==> `DSKeyValueObservance`  

类`NSKeyValueChangeDictionary` ==> `DSKeyValueChangeDictionary`  

...
  
