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
  
  
//////////////补充说明 2017-06-01 18:10//////////////   
有位兄弟说我的这份代码是盗用Apportable的，为了证明清白，也针对对他的质疑做如下说明:   

(0).我今天才知道Apportable这份开源代码,我不确定能不能跑得起来测试  

(1).借助IDA，Hopper等反汇编工具，任何人都可以从OC二进制文件中清晰看出类的继承体系，方法列表(不带参数命名)，Protocol列表，ivar和property列表  

(2).逆向编程的一个基本过程就是翻译,汇编怎么写，就怎么翻译，变量命名不一样，编程风格不同，但是逻辑一定相同  

(3).假设有个selector叫`-(void)setName:age:sex`,很容易推出带参数的版本:`-(void)setName:(NSString *)name age:(int)age sex:(char)sex`  而且90%的人推出来的结果必定相同，因为这是明摆摆的。  
 
 
这位兄弟以我的实现和Apportable实现函数的逻辑相同，oc方法的参数命名相同来断定我是抄袭，就好像说怡宝和百岁山矿泉水的水分子结构完全相同，因此断定怡宝在矿泉水生产技术上抄袭百岁山一样。

真正体现难度的是c函数，结构体及结构体成员，指针含义的推测。

以我的实现和Apportable实现做几点对比: 
#### 举几个结构体的例子

Apportable对几个重要结构体的定义:
```
typedef struct {
    id _field1;
    NSMutableDictionary *recursedMutableDictionary;
} NSKeyValueForwardingValues;

typedef struct {
    NSKeyValueChange _changeKind;
    NSIndexSet *_indexes;
} NSKeyValueChangeByOrderedToManyMutation;

typedef struct {
    NSKeyValueSetMutationKind _mutationKind;
    NSSet *_objects;
} NSKeyValueChangeBySetMutation;

typedef struct {
    Class _originalClass;
    Class _notifyingClass;
    CFMutableSetRef _field3;
    CFMutableDictionaryRef _cachedKeys;
} NSKVONotifyingInfo;

typedef struct {
    Class alwaysNilFakeIsa;
    NSKeyValueContainerClass *containerClass;
    NSString *keyPath;
} NSKVOFakeProperty;

typedef struct {
    NSObject *originalObservable;
    NSKeyValueObservance *observance;
} NSKeyValueImplicitObservanceAdditionInfo;

typedef struct {
    NSObject *nextObject;
    NSKeyValueObservance *observingObservance;
    NSString *keyPath;
    NSObject *originalObservable;
    NSKeyValueProperty *property;
    BOOL isRecursing; //?
} NSKeyValueImplicitObservanceRemovalInfo;

typedef struct {
    CFMutableArrayRef pendingNotifications;
    BOOL nextIsObservationInfo;
    union {
        NSKeyValueImplicitObservanceAdditionInfo implicitObservanceAdditionInfo;
        NSKeyValueObservationInfo *observationInfo;
    } implicitObservanceAdditionInfoOrObservationInfo;
    NSKeyValueImplicitObservanceRemovalInfo implicitObservanceRemovalInfo;
    NSInteger recursionLevel;
} NSKeyValueObservingTSD;

typedef struct {
    short retainCount;
    BOOL reserved;
    NSObject *originalObservable;
    NSObject *observer;
    id keyOrKeys;
    NSKeyValueObservationInfo *observationInfo;
    NSKeyValueObservance *observance;
    NSKeyValueChangeDetails changeDetails;
    NSKeyValueForwardingValues forwardingValues;
    NSInteger recursionLevel;
} NSKVOPendingNotificationInfo;

typedef struct {
    CFMutableArrayRef pendingNotifications;
    NSInteger pendingNotificationCount;
    NSKVOPendingNotificationInfo *relevantNotification;
    NSInteger relevantNotificationIndex;
    NSKeyValueObservance *observance;
    NSInteger recursionLevel;
} NSKVOPopNotificationResult;
```
我的定义
```
typedef struct {
    id changingValue;
    NSMutableDictionary *affectingValuesMap;
}DSKeyValuePropertyForwardingValues;

typedef struct {
    //引用计数
    uint16_t retainCount;
    //是否是一次change的起始
    BOOL beginningOfChange;
    
    id object;//4
    id keyOrKeys;//8
    DSKeyValueObservationInfo *observationInfo;//c
    DSKeyValueObservance *observance;//10
    NSKeyValueChange kind;//14
    id oldValue;//18
    id newValue;//1c
    NSIndexSet *indexes;//20
    NSMutableData * extraData;//24
    id changingValue;//28
    NSMutableDictionary *affectingValuesMap;//2c
}DSKVOPendingChangeNotificationPerThread;

typedef struct {
    CFMutableArrayRef pendingArray;//0
    BOOL beginningOfChange;//4
    DSKeyValueObservationInfo *observationInfo;//8
}DSKVOPushInfoPerThread;

typedef struct {
    CFMutableArrayRef pendingArray;//0
    NSUInteger pendingCount;//4
    DSKVOPendingChangeNotificationPerThread * lastPopedNotification;//8
    NSInteger lastPopdIndex;//c
    DSKeyValueObservance * observance;//10
}DSKVOPopInfoPerThread;

typedef struct DSKeyValueNotifyingInfo {
    Class originalClass;
    Class newSubClass;
    CFMutableSetRef notifyingKeys;
    CFMutableDictionaryRef selKeyMap;
    pthread_mutex_t mutex;
    //originalClass类是否覆写了 willChangeValueForKey: 或  didChangeValueForKey:
    BOOL overrideWillOrDidChange;
}DSKeyValueNotifyingInfo;

typedef union {
    struct {
        NSKeyValueChange changeKind;
        NSIndexSet *indexes;
    };
    struct {
        NSKeyValueSetMutationKind mutationKind;
        NSSet *objects;
    };
}DSKVOCollectionWillChangeInfo;

typedef struct {
    DSKeyValueObservance *observance;
    NSKeyValueChange kind;
    id oldValue;
    id newValue;
    NSIndexSet *indexes;
    NSMutableData * extraData;
    id changingValue;
    NSMutableDictionary * affectingValuesMap;
    //??以下字段无法推断命名及含义，并且在KVO中无作用
    BOOL unknow_1;
    NSString *keyOrKeys;
}DSKVOPendingChangeNotificationLocal;

typedef struct {
    NSUInteger capacity;
    BOOL notificationsInStack;
    DSKVOPendingChangeNotificationLocal *notifications;
    NSUInteger notificationCount;
     //??以下字段无法推断命名及含义，并且在KVO中无作用
    BOOL unknow_1;
    id unknow_2;
}DSKVOPushInfoLocal;

typedef struct {
    DSKVOPendingChangeNotificationLocal *notifications;
    NSUInteger notificationCount;
    id observer;
    id oldValue;
    id lastChangingValue;
    DSKeyValueObservationInfo *observationInfo;
}DSKVOPopInfoLocal;
```
两种实现都有些字段含义无法推断出，其次大部分相同用途的结构体字段含义，内存布局，完全不同

#### 再举个细节例子

在自动通知模式下,如果被监听对象自己覆写了`willChangeValueForKey:`或者`didChangeValueForKey:`方法，整个通知路径走的就会是另一条，这个特征Apportable没有实现,有兴趣的朋友可以打个断点测试一下

#### 最后举一个Apportable没有解决的BUG，我帮他找出了没能解决的原因
![image](http://oem96wx6v.bkt.clouddn.com/apportable_bug.png)

这个bug的基本原理就是:  
当手动或自动调用`willChangeValueForKey:`时，会PUSH和监听者对象数目相同的待触发通知到一个队列(其实是当栈用)，调用`didChangeValueForKey:`时，会POP这些通知，然后做相应组装之后一一回调给监听者。但是这个队列是线程本地存储的，也就是相对当前线程来说，是个全局变量，队列里很有可能存有其他和本次`will/didChange`操作不相关的通知，因此POP时需要一个"边界"，指示何时POP结束，这个“边界”就是一个BOOL标志，Apportable叫它`reserved`,我叫它`beginningOfChange`，在一次`willChange`引起的PUSH中，第一次PUSH进去的通知，这个标志总是为YES,而后续PUSH进来的通知，这个标志就必定会为NO,这个标志的控制是由`_NSKeyValuePushPendingNotificationPerThread`函数的最后一条MOV指令来设置的，以Apportale的实现来举例，在`_NSKVOPendingNotificationRelease`之后，应当还有一条赋值语句"kvoTSD->nextIsObservationInfo = NO".(而且这个字段命名为`nextIsObservationInfo`明显是不合理的)，这样的话，后续PUSH进来的通知，它的`reserved`标志就会为NO。Apportable之所以强行注释掉上图标示的`return NO`,就是因为没找到这个标志为何“总为YES”的原因，如果这个BUG不解决，那么当多个监听者添加到一个对象上之后，当对象发生改变，只有最后一个添加的监听者能收到通知.
