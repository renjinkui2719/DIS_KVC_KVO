#import "tests_define.h"
#import "DSKeyValueObservance.h"

__unused static void *CONTEXT_1 = "CONTEXT_1";
__unused static void *CONTEXT_2 = "CONTEXT_2";
__unused static void *CONTEXT_3 = "CONTEXT_3";
__unused static void *CONTEXT_4 = "CONTEXT_4";
__unused static void *CONTEXT_5 = "CONTEXT_5";
__unused static void *CONTEXT_6 = "CONTEXT_6";

void kvo_tests_main() {
    void kvo_add_remove();
    void kvo_notify();
    NEW_LINE
    NEW_LINE
    SEP_LINE
    kvo_add_remove();
    SEP_LINE
    kvo_notify();
    SEP_LINE
    NEW_LINE
}

void kvo_notify() {
    //==================监听与通知===============
    //和系统 KVO进行对比测试，以结果是否和系统KVO结果相同来评判测试是否通过
    
    __unused ObserverA *obserVerA = [ObserverA new];
    __unused ObserverB *obserVerB = [ObserverB new];
    __unused ObserverC *obserVerC = [ObserverC new];
    __unused ObserverD *obserVerD = [ObserverD new];
    
    __block __unused A *a = NextRandomA_1;
    __block __unused KVONotifyResult *result1 = nil;
    __block __unused KVONotifyResult *result2 = nil;
    __block __unused KVONotifyResult *result3= nil;
    __block __unused KVONotifyResult *result4 = nil;
    
    NSKeyValueObservingOptions options_all = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionOld;
#if AUTO_NOTIFY_ON
    
    {
        //====简单keyPath==
        a = NextRandomA_1;
        [a d_addObserver:obserVerA forKeyPath:@"int_field" options:options_all context:CONTEXT_1];
        a.int_field = 20;
        result1 = PICK_NOTIFY_RESULT_PERTHREAD();
        [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
        
        [a addObserver:obserVerA forKeyPath:@"int_field" options:options_all context:CONTEXT_1];
        a.int_field = 20;
        result2 = PICK_NOTIFY_RESULT_PERTHREAD();
        [a removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
        
        TEST([result1 isEqual:result2]);
        
    }
    
    {
        //====嵌套keyPath,监听的传递 ==
        a = NextRandomA_1;
        a.B_field = B.random;
        a.B_field.C_field = C.random;
        a.B_field.C_field.D_field = D.random;
        a.B_field.C_field.D_field.E_field = E.random;
        a.B_field.C_field.D_field.E_field.F_field = F.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field = B.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field = C.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field = D.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field = E.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field = F.random;
        
        [a d_addObserver:obserVerA forKeyPath:@"B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.int_field" options:options_all context:CONTEXT_1];
        a.B_field = B.random;
        a.B_field.C_field.D_field.E_field = E.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field = D.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field = F.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.int_field = 200;
        result1 = PICK_NOTIFY_RESULT_PERTHREAD();
        [a d_removeObserver:obserVerA forKeyPath:@"B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.int_field" context:CONTEXT_1];

        [a addObserver:obserVerA forKeyPath:@"B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.int_field" options:options_all context:CONTEXT_1];
        a.B_field = B.random;
        a.B_field.C_field.D_field.E_field = E.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field = D.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field = F.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.int_field = 200;
        result2 = PICK_NOTIFY_RESULT_PERTHREAD();
        [a removeObserver:obserVerA forKeyPath:@"B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.int_field" context:CONTEXT_1];
        
        TEST([result1 isEqual:result2]);
        
    }
    
#if AFFECTING_KEY_PATH_TEST_ON
    {
        //====依赖keyPath && 监听传递==
        a = NextRandomA_1;
        a.B_field = B.random;
        a.C_field = C.random;
        a.D_field = D.random;
        a.E_field = E.random;
        a.F_field = F.random;
        //B_field --依赖--> E_field
        //B_field --依赖--> F_field
        //B_field --依赖--> C_field.char_field
        //C_field --依赖--> D_field.char_field
        
        [a d_addObserver:obserVerA forKeyPath:@"B_field" options:options_all context:CONTEXT_1];
        a.D_field.char_field = 'c';
        a.C_field.char_field = 'c';
        a.E_field = E.random;
        a.F_field = F.random;
        result1 = PICK_NOTIFY_RESULT_PERTHREAD();
        [a d_removeObserver:obserVerA forKeyPath:@"B_field" context:CONTEXT_1];
        
        [a addObserver:obserVerA forKeyPath:@"B_field" options:options_all context:CONTEXT_1];
        a.D_field.char_field = 'c';
        a.C_field.char_field = 'c';
        a.E_field = E.random;
        a.F_field = F.random;
        result2 = PICK_NOTIFY_RESULT_PERTHREAD();
        [a removeObserver:obserVerA forKeyPath:@"B_field" context:CONTEXT_1];
        
        TEST([result1 isEqual:result2]);
    }
#endif
    
    {
        //======监听集合属性====
        //NSArray
#if NSARRAY_MUTE_BY_CONTAINER
        {
            //a 对 NSArray_field的管理方法 修改Array
            a = NextRandomA_1;
            a.NSArray_field = [NSMutableArray array];
            [a d_addObserver:obserVerA forKeyPath:@"NSArray_field" options:options_all context:CONTEXT_1];
            a.NSArray_field = [NSMutableArray arrayWithArray:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1]];
            [a insertObject:NextRandomA_1 inNSArray_fieldAtIndex:0];
            [a insertObject:NextRandomA_1 inNSArray_fieldAtIndex:5];
            [a insertObject:NextRandomA_1 inNSArray_fieldAtIndex:a.NSArray_field.count];
            
            [a removeObjectFromNSArray_fieldAtIndex:0];
            [a removeObjectFromNSArray_fieldAtIndex:5];
            [a removeObjectFromNSArray_fieldAtIndex:a.NSArray_field.count - 1];
            
            [a replaceObjectInNSArray_fieldAtIndex:0 withObject:NextRandomA_1];
            [a replaceObjectInNSArray_fieldAtIndex:5 withObject:NextRandomA_1];
            [a replaceObjectInNSArray_fieldAtIndex:a.NSArray_field.count - 1 withObject:NextRandomA_1];
            
            [a insertNSArray_field:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [a insertNSArray_field:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [a insertNSArray_field:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSArray_field.count - 1, 4)]];
            
            [a removeNSArray_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [a removeNSArray_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [a removeNSArray_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSArray_field.count - 4, 4)]];
            
            [a replaceNSArray_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] withNSArray_field:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1]];
            [a replaceNSArray_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)] withNSArray_field:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1]];
            [a replaceNSArray_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSArray_field.count - 4, 4)] withNSArray_field:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1]];
            
            result1 = PICK_NOTIFY_RESULT_PERTHREAD();
            
            [a d_removeObserver:obserVerA forKeyPath:@"NSArray_field" context:CONTEXT_1];
            
            
            
            a.NSArray_field = [NSMutableArray array];
            [a addObserver:obserVerA forKeyPath:@"NSArray_field" options:options_all context:CONTEXT_1];
            a.NSArray_field = [NSMutableArray arrayWithArray:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1]];
            [a insertObject:NextRandomA_1 inNSArray_fieldAtIndex:0];
            [a insertObject:NextRandomA_1 inNSArray_fieldAtIndex:5];
            [a insertObject:NextRandomA_1 inNSArray_fieldAtIndex:a.NSArray_field.count];
            
            [a removeObjectFromNSArray_fieldAtIndex:0];
            [a removeObjectFromNSArray_fieldAtIndex:5];
            [a removeObjectFromNSArray_fieldAtIndex:a.NSArray_field.count - 1];
            
            [a replaceObjectInNSArray_fieldAtIndex:0 withObject:NextRandomA_1];
            [a replaceObjectInNSArray_fieldAtIndex:5 withObject:NextRandomA_1];
            [a replaceObjectInNSArray_fieldAtIndex:a.NSArray_field.count - 1 withObject:NextRandomA_1];
            
            [a insertNSArray_field:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [a insertNSArray_field:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [a insertNSArray_field:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSArray_field.count - 1, 4)]];
            
            [a removeNSArray_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [a removeNSArray_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [a removeNSArray_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSArray_field.count - 4, 4)]];
            
            [a replaceNSArray_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] withNSArray_field:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1]];
            [a replaceNSArray_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)] withNSArray_field:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1]];
            [a replaceNSArray_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSArray_field.count - 4, 4)] withNSArray_field:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1]];
            
            result2 = PICK_NOTIFY_RESULT_PERTHREAD();
            
            [a removeObserver:obserVerA forKeyPath:@"NSArray_field" context:CONTEXT_1];
            
            TEST([result1 isEqual:result2]);
        }
#endif
        {
            //通过代理对象修改NSArray
            a = NextRandomA_1;
            a.NSArray_field = [NSMutableArray array];
            [a d_addObserver:obserVerA forKeyPath:@"NSArray_field" options:options_all context:CONTEXT_1];
            a.NSArray_field = [NSMutableArray arrayWithArray:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1]];
            NSMutableArray *proxy = [a d_mutableArrayValueForKey:@"NSArray_field"];
            [proxy insertObject:NextRandomA_1 atIndex:0];
            [proxy insertObject:NextRandomA_1 atIndex:5];
            [proxy insertObject:NextRandomA_1 atIndex:proxy.count];
            
            [proxy removeObjectAtIndex:0];
            [proxy removeObjectAtIndex:5];
            [proxy removeObjectAtIndex:proxy.count - 1];
            
            [proxy replaceObjectAtIndex:0 withObject:NextRandomA_1];
            [proxy replaceObjectAtIndex:5 withObject:NextRandomA_1];
            [proxy replaceObjectAtIndex:proxy.count - 1 withObject:NextRandomA_1];
            
            [proxy insertObjects:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [proxy insertObjects:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [proxy insertObjects:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(proxy.count - 1, 4)]];
            
            [proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(proxy.count - 4, 4)]];
            
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] withObjects:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1]];
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)] withObjects:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1]];
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(proxy.count - 4, 4)] withObjects:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1]];
            
            result1 = PICK_NOTIFY_RESULT_PERTHREAD();
            
            [a d_removeObserver:obserVerA forKeyPath:@"NSArray_field" context:CONTEXT_1];
            
            
            a.NSArray_field = [NSMutableArray array];
            [a addObserver:obserVerA forKeyPath:@"NSArray_field" options:options_all context:CONTEXT_1];
            a.NSArray_field = [NSMutableArray arrayWithArray:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1,NextRandomA_1]];
            proxy = [a mutableArrayValueForKey:@"NSArray_field"];
            [proxy insertObject:NextRandomA_1 atIndex:0];
            [proxy insertObject:NextRandomA_1 atIndex:5];
            [proxy insertObject:NextRandomA_1 atIndex:proxy.count];
            
            [proxy removeObjectAtIndex:0];
            [proxy removeObjectAtIndex:5];
            [proxy removeObjectAtIndex:proxy.count - 1];
            
            [proxy replaceObjectAtIndex:0 withObject:NextRandomA_1];
            [proxy replaceObjectAtIndex:5 withObject:NextRandomA_1];
            [proxy replaceObjectAtIndex:proxy.count - 1 withObject:NextRandomA_1];
            
            [proxy insertObjects:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [proxy insertObjects:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [proxy insertObjects:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(proxy.count - 1, 4)]];
            
            [proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(proxy.count - 4, 4)]];
            
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] withObjects:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1]];
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)] withObjects:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1]];
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(proxy.count - 4, 4)] withObjects:@[NextRandomA_1, NextRandomA_1, NextRandomA_1, NextRandomA_1]];
            
            result2 = PICK_NOTIFY_RESULT_PERTHREAD();
            
            [a removeObserver:obserVerA forKeyPath:@"NSArray_field" context:CONTEXT_1];
            
            TEST([result1 isEqual:result2]);
        }
        
        //NSSet
#if NSSET_MUTE_BY_CONTAINER
        {
            a = NextRandomA_1;
            a.NSSet_field = [NSMutableSet set];
            [a d_addObserver:obserVerA forKeyPath:@"NSSet_field" options:options_all context:CONTEXT_1];
            a.NSSet_field = [NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"], [A randomWithIdentifier:@"003"], [A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"007"], [A randomWithIdentifier:@"008"], [A randomWithIdentifier:@"009"], [A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], [A randomWithIdentifier:@"012"], [A randomWithIdentifier:@"013"], [A randomWithIdentifier:@"014"], [A randomWithIdentifier:@"015"],[A randomWithIdentifier:@"016"], [A randomWithIdentifier:@"017"], [A randomWithIdentifier:@"018"], [A randomWithIdentifier:@"019"], [A randomWithIdentifier:@"020"],[A randomWithIdentifier:@"021"]]];
            
            [a addNSSet_fieldObject:[A randomWithIdentifier:@"022"]];
            [a removeNSSet_fieldObject:[A randomWithIdentifier:@"005"]];
            [a intersectNSSet_field:[NSSet setWithObjects:[A randomWithIdentifier:@"022"],[A randomWithIdentifier:@"023"],[A randomWithIdentifier:@"024"],[A randomWithIdentifier:@"020"], nil]];
            [a removeNSSet_field:[NSSet setWithObjects:[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], nil]];
            [a addNSSet_field:[NSSet setWithObjects:[A randomWithIdentifier:@"023"],[A randomWithIdentifier:@"025"],[A randomWithIdentifier:@"026"],[A randomWithIdentifier:@"027"], nil]];
            [a setNSSet_field:[NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"], [A randomWithIdentifier:@"003"], [A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"007"], [A randomWithIdentifier:@"008"], [A randomWithIdentifier:@"009"], [A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], [A randomWithIdentifier:@"012"], [A randomWithIdentifier:@"013"], [A randomWithIdentifier:@"014"], [A randomWithIdentifier:@"015"],[A randomWithIdentifier:@"016"], [A randomWithIdentifier:@"017"], [A randomWithIdentifier:@"018"], [A randomWithIdentifier:@"019"], [A randomWithIdentifier:@"020"],[A randomWithIdentifier:@"021"]]]];
            result1 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a d_removeObserver:obserVerA forKeyPath:@"NSSet_field" context:CONTEXT_1];
         
            a.NSSet_field = [NSMutableSet set];
            [a addObserver:obserVerA forKeyPath:@"NSSet_field" options:options_all context:CONTEXT_1];
            a.NSSet_field = [NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"], [A randomWithIdentifier:@"003"], [A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"007"], [A randomWithIdentifier:@"008"], [A randomWithIdentifier:@"009"], [A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], [A randomWithIdentifier:@"012"], [A randomWithIdentifier:@"013"], [A randomWithIdentifier:@"014"], [A randomWithIdentifier:@"015"],[A randomWithIdentifier:@"016"], [A randomWithIdentifier:@"017"], [A randomWithIdentifier:@"018"], [A randomWithIdentifier:@"019"], [A randomWithIdentifier:@"020"],[A randomWithIdentifier:@"021"]]];
            
            [a addNSSet_fieldObject:[A randomWithIdentifier:@"022"]];
            [a removeNSSet_fieldObject:[A randomWithIdentifier:@"005"]];
            [a intersectNSSet_field:[NSSet setWithObjects:[A randomWithIdentifier:@"022"],[A randomWithIdentifier:@"023"],[A randomWithIdentifier:@"024"],[A randomWithIdentifier:@"020"], nil]];
            [a removeNSSet_field:[NSSet setWithObjects:[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], nil]];
            [a addNSSet_field:[NSSet setWithObjects:[A randomWithIdentifier:@"023"],[A randomWithIdentifier:@"025"],[A randomWithIdentifier:@"026"],[A randomWithIdentifier:@"027"], nil]];
            [a setNSSet_field:[NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"], [A randomWithIdentifier:@"003"], [A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"007"], [A randomWithIdentifier:@"008"], [A randomWithIdentifier:@"009"], [A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], [A randomWithIdentifier:@"012"], [A randomWithIdentifier:@"013"], [A randomWithIdentifier:@"014"], [A randomWithIdentifier:@"015"],[A randomWithIdentifier:@"016"], [A randomWithIdentifier:@"017"], [A randomWithIdentifier:@"018"], [A randomWithIdentifier:@"019"], [A randomWithIdentifier:@"020"],[A randomWithIdentifier:@"021"]]]];
            result2 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a removeObserver:obserVerA forKeyPath:@"NSSet_field" context:CONTEXT_1];
            
            TEST([result1 isEqual:result2]);
        }
#endif
        {
            a = NextRandomA_1;
            a.NSSet_field = [NSMutableSet set];
            [a d_addObserver:obserVerA forKeyPath:@"NSSet_field" options:options_all context:CONTEXT_1];
            a.NSSet_field = [NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"], [A randomWithIdentifier:@"003"], [A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"007"], [A randomWithIdentifier:@"008"], [A randomWithIdentifier:@"009"], [A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], [A randomWithIdentifier:@"012"], [A randomWithIdentifier:@"013"], [A randomWithIdentifier:@"014"], [A randomWithIdentifier:@"015"],[A randomWithIdentifier:@"016"], [A randomWithIdentifier:@"017"], [A randomWithIdentifier:@"018"], [A randomWithIdentifier:@"019"], [A randomWithIdentifier:@"020"],[A randomWithIdentifier:@"021"]]];
            
            NSMutableSet *proxy = [a d_mutableSetValueForKey:@"NSSet_field"];
            
            [proxy addObject:[A randomWithIdentifier:@"022"]];
            [proxy removeObject:[A randomWithIdentifier:@"005"]];
            [proxy intersectSet:[NSSet setWithObjects:[A randomWithIdentifier:@"022"],[A randomWithIdentifier:@"023"],[A randomWithIdentifier:@"024"],[A randomWithIdentifier:@"020"], nil]];
            [proxy minusSet:[NSSet setWithObjects:[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], nil]];
            [proxy unionSet:[NSSet setWithObjects:[A randomWithIdentifier:@"023"],[A randomWithIdentifier:@"025"],[A randomWithIdentifier:@"026"],[A randomWithIdentifier:@"027"], nil]];
            [proxy setSet:[NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"], [A randomWithIdentifier:@"003"], [A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"007"], [A randomWithIdentifier:@"008"], [A randomWithIdentifier:@"009"], [A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], [A randomWithIdentifier:@"012"], [A randomWithIdentifier:@"013"], [A randomWithIdentifier:@"014"], [A randomWithIdentifier:@"015"],[A randomWithIdentifier:@"016"], [A randomWithIdentifier:@"017"], [A randomWithIdentifier:@"018"], [A randomWithIdentifier:@"019"], [A randomWithIdentifier:@"020"],[A randomWithIdentifier:@"021"]]]];
            result1 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a d_removeObserver:obserVerA forKeyPath:@"NSSet_field" context:CONTEXT_1];
            
            a.NSSet_field = [NSMutableSet set];
            [a addObserver:obserVerA forKeyPath:@"NSSet_field" options:options_all context:CONTEXT_1];
            a.NSSet_field = [NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"], [A randomWithIdentifier:@"003"], [A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"007"], [A randomWithIdentifier:@"008"], [A randomWithIdentifier:@"009"], [A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], [A randomWithIdentifier:@"012"], [A randomWithIdentifier:@"013"], [A randomWithIdentifier:@"014"], [A randomWithIdentifier:@"015"],[A randomWithIdentifier:@"016"], [A randomWithIdentifier:@"017"], [A randomWithIdentifier:@"018"], [A randomWithIdentifier:@"019"], [A randomWithIdentifier:@"020"],[A randomWithIdentifier:@"021"]]];
            
            proxy = [a mutableSetValueForKey:@"NSSet_field"];
            
            [proxy addObject:[A randomWithIdentifier:@"022"]];
            [proxy removeObject:[A randomWithIdentifier:@"005"]];
            [proxy intersectSet:[NSSet setWithObjects:[A randomWithIdentifier:@"022"],[A randomWithIdentifier:@"023"],[A randomWithIdentifier:@"024"],[A randomWithIdentifier:@"020"], nil]];
            [proxy minusSet:[NSSet setWithObjects:[A randomWithIdentifier:@"009"],[A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], nil]];
            [proxy unionSet:[NSSet setWithObjects:[A randomWithIdentifier:@"023"],[A randomWithIdentifier:@"025"],[A randomWithIdentifier:@"026"],[A randomWithIdentifier:@"027"], nil]];
            [proxy setSet:[NSMutableSet setWithArray:@[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"], [A randomWithIdentifier:@"003"], [A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"007"], [A randomWithIdentifier:@"008"], [A randomWithIdentifier:@"009"], [A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], [A randomWithIdentifier:@"012"], [A randomWithIdentifier:@"013"], [A randomWithIdentifier:@"014"], [A randomWithIdentifier:@"015"],[A randomWithIdentifier:@"016"], [A randomWithIdentifier:@"017"], [A randomWithIdentifier:@"018"], [A randomWithIdentifier:@"019"], [A randomWithIdentifier:@"020"],[A randomWithIdentifier:@"021"]]]];
            result2 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a removeObserver:obserVerA forKeyPath:@"NSSet_field" context:CONTEXT_1];
            
            TEST([result1 isEqual:result2]);
        }
        
        //NSOrderedSet
#if NSORDEDSET_MUTE_BY_CONTAINER
        {
            a = NextRandomA_1;
            a.NSOrderedSet_field = [NSMutableOrderedSet orderedSet];
            [a d_addObserver:obserVerA forKeyPath:@"NSOrderedSet_field" options:options_all context:CONTEXT_1];
            a.NSOrderedSet_field = [NSMutableOrderedSet orderedSetWithArray:@[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"], [A randomWithIdentifier:@"003"], [A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"007"], [A randomWithIdentifier:@"008"], [A randomWithIdentifier:@"009"], [A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], [A randomWithIdentifier:@"012"], [A randomWithIdentifier:@"013"], [A randomWithIdentifier:@"014"], [A randomWithIdentifier:@"015"],[A randomWithIdentifier:@"016"], [A randomWithIdentifier:@"017"], [A randomWithIdentifier:@"018"], [A randomWithIdentifier:@"019"], [A randomWithIdentifier:@"020"],[A randomWithIdentifier:@"021"]]];
            [a insertObject:[A randomWithIdentifier:@"022"] inNSOrderedSet_fieldAtIndex:0];
            [a insertObject:[A randomWithIdentifier:@"023"] inNSOrderedSet_fieldAtIndex:5];
            [a insertObject:[A randomWithIdentifier:@"024"] inNSOrderedSet_fieldAtIndex:a.NSOrderedSet_field.count];
            
            [a removeObjectFromNSOrderedSet_fieldAtIndex:0];
            [a removeObjectFromNSOrderedSet_fieldAtIndex:5];
            [a removeObjectFromNSOrderedSet_fieldAtIndex:a.NSOrderedSet_field.count - 1];
            
            [a replaceObjectInNSOrderedSet_fieldAtIndex:0 withObject:[A randomWithIdentifier:@"025"]];
            [a replaceObjectInNSOrderedSet_fieldAtIndex:5 withObject:[A randomWithIdentifier:@"026"]];
            [a replaceObjectInNSOrderedSet_fieldAtIndex:a.NSOrderedSet_field.count - 1 withObject:[A randomWithIdentifier:@"027"]];
            
            [a insertNSOrderedSet_field:@[[A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"030"],[A randomWithIdentifier:@"031"],[A randomWithIdentifier:@"032"]] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [a insertNSOrderedSet_field:@[[A randomWithIdentifier:@"005"], [A randomWithIdentifier:@"033"],[A randomWithIdentifier:@"034"],[A randomWithIdentifier:@"035"]] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [a insertNSOrderedSet_field:@[[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"036"],[A randomWithIdentifier:@"037"],[A randomWithIdentifier:@"038"]] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSOrderedSet_field.count, 4)]];
            
            [a removeNSOrderedSet_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [a removeNSOrderedSet_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [a removeNSOrderedSet_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSOrderedSet_field.count - 4, 4)]];
            
            [a replaceNSOrderedSet_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] withNSOrderedSet_field:@[[A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"030"],[A randomWithIdentifier:@"031"],[A randomWithIdentifier:@"032"]]];
            [a replaceNSOrderedSet_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)] withNSOrderedSet_field:@[[A randomWithIdentifier:@"005"], [A randomWithIdentifier:@"033"],[A randomWithIdentifier:@"034"],[A randomWithIdentifier:@"035"]]];
            [a replaceNSOrderedSet_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSOrderedSet_field.count - 4, 4)] withNSOrderedSet_field:@[[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"036"],[A randomWithIdentifier:@"037"],[A randomWithIdentifier:@"038"]]];
            
            result1 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a d_removeObserver:obserVerA forKeyPath:@"NSOrderedSet_field" context:CONTEXT_1];
            
            a.NSOrderedSet_field = [NSMutableOrderedSet orderedSet];
            [a addObserver:obserVerA forKeyPath:@"NSOrderedSet_field" options:options_all context:CONTEXT_1];
            a.NSOrderedSet_field = [NSMutableOrderedSet orderedSetWithArray:@[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"], [A randomWithIdentifier:@"003"], [A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"007"], [A randomWithIdentifier:@"008"], [A randomWithIdentifier:@"009"], [A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], [A randomWithIdentifier:@"012"], [A randomWithIdentifier:@"013"], [A randomWithIdentifier:@"014"], [A randomWithIdentifier:@"015"],[A randomWithIdentifier:@"016"], [A randomWithIdentifier:@"017"], [A randomWithIdentifier:@"018"], [A randomWithIdentifier:@"019"], [A randomWithIdentifier:@"020"],[A randomWithIdentifier:@"021"]]];
            [a insertObject:[A randomWithIdentifier:@"022"] inNSOrderedSet_fieldAtIndex:0];
            [a insertObject:[A randomWithIdentifier:@"023"] inNSOrderedSet_fieldAtIndex:5];
            [a insertObject:[A randomWithIdentifier:@"024"] inNSOrderedSet_fieldAtIndex:a.NSOrderedSet_field.count];
            
            [a removeObjectFromNSOrderedSet_fieldAtIndex:0];
            [a removeObjectFromNSOrderedSet_fieldAtIndex:5];
            [a removeObjectFromNSOrderedSet_fieldAtIndex:a.NSOrderedSet_field.count - 1];
            
            [a replaceObjectInNSOrderedSet_fieldAtIndex:0 withObject:[A randomWithIdentifier:@"025"]];
            [a replaceObjectInNSOrderedSet_fieldAtIndex:5 withObject:[A randomWithIdentifier:@"026"]];
            [a replaceObjectInNSOrderedSet_fieldAtIndex:a.NSOrderedSet_field.count - 1 withObject:[A randomWithIdentifier:@"027"]];
            
            [a insertNSOrderedSet_field:@[[A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"030"],[A randomWithIdentifier:@"031"],[A randomWithIdentifier:@"032"]] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [a insertNSOrderedSet_field:@[[A randomWithIdentifier:@"005"], [A randomWithIdentifier:@"033"],[A randomWithIdentifier:@"034"],[A randomWithIdentifier:@"035"]] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [a insertNSOrderedSet_field:@[[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"036"],[A randomWithIdentifier:@"037"],[A randomWithIdentifier:@"038"]] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSOrderedSet_field.count, 4)]];
            
            [a removeNSOrderedSet_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [a removeNSOrderedSet_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [a removeNSOrderedSet_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSOrderedSet_field.count - 4, 4)]];
            
            [a replaceNSOrderedSet_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] withNSOrderedSet_field:@[[A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"030"],[A randomWithIdentifier:@"031"],[A randomWithIdentifier:@"032"]]];
            [a replaceNSOrderedSet_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)] withNSOrderedSet_field:@[[A randomWithIdentifier:@"005"], [A randomWithIdentifier:@"033"],[A randomWithIdentifier:@"034"],[A randomWithIdentifier:@"035"]]];
            [a replaceNSOrderedSet_fieldAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSOrderedSet_field.count - 4, 4)] withNSOrderedSet_field:@[[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"036"],[A randomWithIdentifier:@"037"],[A randomWithIdentifier:@"038"]]];
            
            result2 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a removeObserver:obserVerA forKeyPath:@"NSOrderedSet_field" context:CONTEXT_1];
            
            TEST([result1 isEqual:result2]);
        }
#endif
        {
            a = NextRandomA_1;
            a.NSOrderedSet_field = [NSMutableOrderedSet orderedSet];
            [a d_addObserver:obserVerA forKeyPath:@"NSOrderedSet_field" options:options_all context:CONTEXT_1];
            a.NSOrderedSet_field = [NSMutableOrderedSet orderedSetWithArray:@[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"], [A randomWithIdentifier:@"003"], [A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"007"], [A randomWithIdentifier:@"008"], [A randomWithIdentifier:@"009"], [A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], [A randomWithIdentifier:@"012"], [A randomWithIdentifier:@"013"], [A randomWithIdentifier:@"014"], [A randomWithIdentifier:@"015"],[A randomWithIdentifier:@"016"], [A randomWithIdentifier:@"017"], [A randomWithIdentifier:@"018"], [A randomWithIdentifier:@"019"], [A randomWithIdentifier:@"020"],[A randomWithIdentifier:@"021"]]];
            NSMutableOrderedSet *proxy = [a d_mutableOrderedSetValueForKey:@"NSOrderedSet_field"];
            [proxy insertObject:[A randomWithIdentifier:@"022"] atIndex:0];
            [proxy insertObject:[A randomWithIdentifier:@"023"] atIndex:5];
            [proxy insertObject:[A randomWithIdentifier:@"024"] atIndex:a.NSOrderedSet_field.count];
            
            [proxy removeObjectAtIndex:0];
            [proxy removeObjectAtIndex:5];
            [proxy removeObjectAtIndex:a.NSOrderedSet_field.count - 1];
            
            [proxy replaceObjectAtIndex:0 withObject:[A randomWithIdentifier:@"025"]];
            [proxy replaceObjectAtIndex:5 withObject:[A randomWithIdentifier:@"026"]];
            [proxy replaceObjectAtIndex:a.NSOrderedSet_field.count - 1 withObject:[A randomWithIdentifier:@"027"]];
            
            [proxy insertObjects:@[[A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"030"],[A randomWithIdentifier:@"031"],[A randomWithIdentifier:@"032"]] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [proxy insertObjects:@[[A randomWithIdentifier:@"005"], [A randomWithIdentifier:@"033"],[A randomWithIdentifier:@"034"],[A randomWithIdentifier:@"035"]] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [proxy insertObjects:@[[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"036"],[A randomWithIdentifier:@"037"],[A randomWithIdentifier:@"038"]] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSOrderedSet_field.count, 4)]];
            
            [proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSOrderedSet_field.count - 4, 4)]];
            
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] withObjects:@[[A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"030"],[A randomWithIdentifier:@"031"],[A randomWithIdentifier:@"032"]]];
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)] withObjects:@[[A randomWithIdentifier:@"005"], [A randomWithIdentifier:@"033"],[A randomWithIdentifier:@"034"],[A randomWithIdentifier:@"035"]]];
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSOrderedSet_field.count - 4, 4)] withObjects:@[[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"036"],[A randomWithIdentifier:@"037"],[A randomWithIdentifier:@"038"]]];
            
            result1 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a d_removeObserver:obserVerA forKeyPath:@"NSOrderedSet_field" context:CONTEXT_1];
            
            a.NSOrderedSet_field = [NSMutableOrderedSet orderedSet];
            [a addObserver:obserVerA forKeyPath:@"NSOrderedSet_field" options:options_all context:CONTEXT_1];
            a.NSOrderedSet_field = [NSMutableOrderedSet orderedSetWithArray:@[[A randomWithIdentifier:@"001"], [A randomWithIdentifier:@"002"], [A randomWithIdentifier:@"003"], [A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"005"],[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"007"], [A randomWithIdentifier:@"008"], [A randomWithIdentifier:@"009"], [A randomWithIdentifier:@"010"],[A randomWithIdentifier:@"011"], [A randomWithIdentifier:@"012"], [A randomWithIdentifier:@"013"], [A randomWithIdentifier:@"014"], [A randomWithIdentifier:@"015"],[A randomWithIdentifier:@"016"], [A randomWithIdentifier:@"017"], [A randomWithIdentifier:@"018"], [A randomWithIdentifier:@"019"], [A randomWithIdentifier:@"020"],[A randomWithIdentifier:@"021"]]];
            proxy = [a mutableOrderedSetValueForKey:@"NSOrderedSet_field"];
            [proxy insertObject:[A randomWithIdentifier:@"022"] atIndex:0];
            [proxy insertObject:[A randomWithIdentifier:@"023"] atIndex:5];
            [proxy insertObject:[A randomWithIdentifier:@"024"] atIndex:a.NSOrderedSet_field.count];
            
            [proxy removeObjectAtIndex:0];
            [proxy removeObjectAtIndex:5];
            [proxy removeObjectAtIndex:a.NSOrderedSet_field.count - 1];
            
            [proxy replaceObjectAtIndex:0 withObject:[A randomWithIdentifier:@"025"]];
            [proxy replaceObjectAtIndex:5 withObject:[A randomWithIdentifier:@"026"]];
            [proxy replaceObjectAtIndex:a.NSOrderedSet_field.count - 1 withObject:[A randomWithIdentifier:@"027"]];
            
            [proxy insertObjects:@[[A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"030"],[A randomWithIdentifier:@"031"],[A randomWithIdentifier:@"032"]] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [proxy insertObjects:@[[A randomWithIdentifier:@"005"], [A randomWithIdentifier:@"033"],[A randomWithIdentifier:@"034"],[A randomWithIdentifier:@"035"]] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [proxy insertObjects:@[[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"036"],[A randomWithIdentifier:@"037"],[A randomWithIdentifier:@"038"]] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSOrderedSet_field.count, 4)]];
            
            [proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
            [proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)]];
            [proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSOrderedSet_field.count - 4, 4)]];
            
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] withObjects:@[[A randomWithIdentifier:@"004"], [A randomWithIdentifier:@"030"],[A randomWithIdentifier:@"031"],[A randomWithIdentifier:@"032"]]];
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 4)] withObjects:@[[A randomWithIdentifier:@"005"], [A randomWithIdentifier:@"033"],[A randomWithIdentifier:@"034"],[A randomWithIdentifier:@"035"]]];
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(a.NSOrderedSet_field.count - 4, 4)] withObjects:@[[A randomWithIdentifier:@"006"], [A randomWithIdentifier:@"036"],[A randomWithIdentifier:@"037"],[A randomWithIdentifier:@"038"]]];
            
            result2 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a removeObserver:obserVerA forKeyPath:@"NSOrderedSet_field" context:CONTEXT_1];
            
            TEST([result1 isEqual:result2]);
        }
    }
    
#endif
    
#if !AUTO_NOTIFY_ON
    {
        //======手动触发通知====
        {
            A *a = NextRandomA_1;
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:options_all context:CONTEXT_1];
            
            [a d_willChangeValueForKey:@"int_field"];
            a.int_field = 20;
            [a d_didChangeValueForKey:@"int_field"];
            
            result1 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            
            
            [a addObserver:obserVerA forKeyPath:@"int_field" options:options_all context:CONTEXT_1];
            [a willChangeValueForKey:@"int_field"];
            a.int_field = 20;
            [a didChangeValueForKey:@"int_field"];
            result2 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            
            TEST([result1 isEqual:result2]);
            
        }
        {
            //没有will change，只有did change无法触发通知
            A *a = NextRandomA_1;
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            
            a.int_field = 20;
            [a d_didChangeValueForKey:@"int_field"];
            
            result1 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            
            
            [a addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            a.int_field = 20;
            [a didChangeValueForKey:@"int_field"];
            result2 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            
            TEST(result1 == result2 && result1 == nil);
        }
        
        {
            //多次对称调用will/did change，将多次触发通知
            A *a = NextRandomA_1;
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            [a d_willChangeValueForKey:@"int_field"];
            [a d_willChangeValueForKey:@"int_field"];
            [a d_willChangeValueForKey:@"int_field"];
            [a d_willChangeValueForKey:@"int_field"];
            a.int_field = 20;
            [a d_didChangeValueForKey:@"int_field"];
            [a d_didChangeValueForKey:@"int_field"];
            [a d_didChangeValueForKey:@"int_field"];
            [a d_didChangeValueForKey:@"int_field"];
            
            result1 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            
            
            [a addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            [a willChangeValueForKey:@"int_field"];
            [a willChangeValueForKey:@"int_field"];
            [a willChangeValueForKey:@"int_field"];
            [a willChangeValueForKey:@"int_field"];
            a.int_field = 20;
            [a didChangeValueForKey:@"int_field"];
            [a didChangeValueForKey:@"int_field"];
            [a didChangeValueForKey:@"int_field"];
            [a didChangeValueForKey:@"int_field"];
            result2 = PICK_NOTIFY_RESULT_PERTHREAD();
            [a removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            
            TEST(result1.items.count == result2.items.count && result2.items.count == 4 && [result1 isEqual:result2]);
        }
        
        {
            //will change与did change必须在同一线程调用， 否则无法触发通知
            //主线程 will change, 子线程did change
            A *a = NextRandomA_1;
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            
            [a d_willChangeValueForKey:@"int_field"];
            
            a.int_field = 20;
            
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [a d_didChangeValueForKey:@"int_field"];
                result1 = PICK_NOTIFY_RESULT_PERTHREAD();
                dispatch_semaphore_signal(sem);
            });
            //等待子线程执行完成
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            
            if (!result1) {
                result1 = PICK_NOTIFY_RESULT_PERTHREAD();
            }
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            
            
            [a addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            [a willChangeValueForKey:@"int_field"];
            
            a.int_field = 20;
            
            sem = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [a didChangeValueForKey:@"int_field"];
                result2 = PICK_NOTIFY_RESULT_PERTHREAD();
                dispatch_semaphore_signal(sem);
            });
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            
            if (!result2) {
                result2 = PICK_NOTIFY_RESULT_PERTHREAD();
            }
            [a removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            
            TEST(result1 == result2 && result1 == nil);
        }
        
        {
            //在哪个线程will,did change，就在哪个线程收到通知
            
            __block NSThread *thread_2;
            __block NSThread *thread_4;
            
            A *a = NextRandomA_1;
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            
            
            [a d_willChangeValueForKey:@"int_field"];
            
            a.int_field = 20;
            
            [a d_didChangeValueForKey:@"int_field"];
            
            result1 = PICK_NOTIFY_RESULT_PERTHREAD();
            
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [a d_willChangeValueForKey:@"int_field"];
                
                a.int_field = 20;
                
                [a d_didChangeValueForKey:@"int_field"];
                
                result2 = PICK_NOTIFY_RESULT_PERTHREAD().retain;
                thread_2 = [NSThread currentThread].retain;
                dispatch_semaphore_signal(sem);
            });
            //等待子线程执行完成
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            
            
            [a addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            [a willChangeValueForKey:@"int_field"];
            
            a.int_field = 20;
            
            [a didChangeValueForKey:@"int_field"];
            
            result3 = PICK_NOTIFY_RESULT_PERTHREAD();
            
            sem = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [a willChangeValueForKey:@"int_field"];
                
                a.int_field = 20;
                
                [a didChangeValueForKey:@"int_field"];
                
                result4 = PICK_NOTIFY_RESULT_PERTHREAD().retain;
                thread_4 = [NSThread currentThread].retain;
                dispatch_semaphore_signal(sem);
            });
            //等待子线程执行完成
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            
            [a removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            
            TEST(([result1 isEqual:result2] && [result2 isEqual:result3] && [result3 isEqual:result4]) && (result1.thread == [NSThread mainThread] && result2.thread == thread_2 && result3.thread == [NSThread mainThread] && result4.thread == thread_4));
        }
    }
#endif
    
}

void kvo_add_remove() {
    //======================监听的添加与移除======================
    __unused ObserverA *obserVerA = [ObserverA new];
    __unused ObserverB *obserVerB = [ObserverB new];
    __unused ObserverC *obserVerC = [ObserverC new];
    __unused ObserverD *obserVerD = [ObserverD new];
#if AUTO_NOTIFY_ON
    A *a = NextRandomA_1;
    {
        //====简单keyPath==
        a = NextRandomA_1;
        [a d_addObserver:obserVerA forKeyPath:@"char_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
        //添加监听后， a.class获取的类仍然是A, 但是object_getClass(a)获取的"真实类"是DSKVONotifying_A
        TEST(a.class == NSClassFromString(@"A") && object_getClass(a) == NSClassFromString(@"DSKVONotifying_A"));
        [a d_removeObserver:obserVerA forKeyPath:@"char_field" context:CONTEXT_1];
        //移除监听后， 类复原
        TEST(a.class == NSClassFromString(@"A") && object_getClass(a) == NSClassFromString(@"A"));
    }
    
    {
        //====嵌套keyPath,监听的传递 ==
        a = NextRandomA_1;
        a.B_field = B.random;
        a.B_field.C_field = C.random;
        a.B_field.C_field.D_field = D.random;
        a.B_field.C_field.D_field.E_field = E.random;
        a.B_field.C_field.D_field.E_field.F_field = F.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field = B.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field = C.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field = D.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field = E.random;
        a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field = F.random;
        
        [a d_addObserver:obserVerA forKeyPath:@"B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.char_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
        //a 的 B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.char_field keyPath 应该被监听
        //a.B_field 的 C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.char_field keyPath 应该被监听
        //a.B_field.C_field 的 D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.char_field keyPath 应该被监听
        //a.B_field.C_field.D_field 的 E_field.F_field.B_field.C_field.D_field.E_field.F_field.char_field keyPath 应该被监听
        //a.B_field.C_field.D_field.E_field 的 F_field.B_field.C_field.D_field.E_field.F_field.char_field keyPath 应该被监听
        //a.B_field.C_field.D_field.E_field.F_field 的 B_field.C_field.D_field.E_field.F_field.char_field keyPath 应该被监听
        //a.B_field.C_field.D_field.E_field.F_field.B_field 的 C_field.D_field.E_field.F_field.char_field keyPath 应该被监听
        //...
        //a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field 的 char_field keyPath 应该被监听
        
        {
            TEST(a.class == NSClassFromString(@"A") && object_getClass(a) == NSClassFromString(@"DSKVONotifying_A"));
            id observance = [[(id)a.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.char_field"]);
        }
        {
            TEST(a.B_field.class == NSClassFromString(@"B") && object_getClass(a.B_field) == NSClassFromString(@"DSKVONotifying_B"));
            id observance = [[(id)a.B_field.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.char_field"]);
        }
        {
            TEST(a.B_field.C_field.class == NSClassFromString(@"C") && object_getClass(a.B_field.C_field) == NSClassFromString(@"DSKVONotifying_C"));
            id observance = [[(id)a.B_field.C_field.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.char_field"]);
        }
        {
            TEST(a.B_field.C_field.D_field.class == NSClassFromString(@"D") && object_getClass(a.B_field.C_field.D_field) == NSClassFromString(@"DSKVONotifying_D"));
            id observance = [[(id)a.B_field.C_field.D_field.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"E_field.F_field.B_field.C_field.D_field.E_field.F_field.char_field"]);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.class == NSClassFromString(@"E") && object_getClass(a.B_field.C_field.D_field.E_field) == NSClassFromString(@"DSKVONotifying_E"));
            id observance = [[(id)a.B_field.C_field.D_field.E_field.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"F_field.B_field.C_field.D_field.E_field.F_field.char_field"]);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.F_field.class == NSClassFromString(@"F") && object_getClass(a.B_field.C_field.D_field.E_field.F_field) == NSClassFromString(@"DSKVONotifying_F"));
            id observance = [[(id)a.B_field.C_field.D_field.E_field.F_field.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"B_field.C_field.D_field.E_field.F_field.char_field"]);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.class == NSClassFromString(@"B") && object_getClass(a.B_field.C_field.D_field.E_field.F_field.B_field) == NSClassFromString(@"DSKVONotifying_B"));
            id observance = [[(id)a.B_field.C_field.D_field.E_field.F_field.B_field.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"C_field.D_field.E_field.F_field.char_field"]);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.class == NSClassFromString(@"C") && object_getClass(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field) == NSClassFromString(@"DSKVONotifying_C"));
            id observance = [[(id)a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"D_field.E_field.F_field.char_field"]);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.class == NSClassFromString(@"D") && object_getClass(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field) == NSClassFromString(@"DSKVONotifying_D"));
            id observance = [[(id)a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"E_field.F_field.char_field"]);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.class == NSClassFromString(@"E") && object_getClass(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field) == NSClassFromString(@"DSKVONotifying_E"));
            id observance = [[(id)a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"F_field.char_field"]);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.class == NSClassFromString(@"F") && object_getClass(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field) == NSClassFromString(@"DSKVONotifying_F"));
            id observance = [[(id)a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"char_field"]);
        }
        
        [a d_removeObserver:obserVerA forKeyPath:@"B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.char_field" context:CONTEXT_1];
        
        //移除监听后，整条监听链复原
        
        {
            TEST(a.class == NSClassFromString(@"A") && object_getClass(a) == NSClassFromString(@"A"));
            TEST(a.d_observationInfo == NULL);
        }
        {
            TEST(a.B_field.class == NSClassFromString(@"B") && object_getClass(a.B_field) == NSClassFromString(@"B"));
            TEST(a.B_field.d_observationInfo == NULL);
        }
        {
            TEST(a.B_field.C_field.class == NSClassFromString(@"C") && object_getClass(a.B_field.C_field) == NSClassFromString(@"C"));
            TEST(a.B_field.C_field.d_observationInfo == NULL);
        }
        {
            TEST(a.B_field.C_field.D_field.class == NSClassFromString(@"D") && object_getClass(a.B_field.C_field.D_field) == NSClassFromString(@"D"));
            TEST(a.B_field.C_field.D_field.d_observationInfo == NULL);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.class == NSClassFromString(@"E") && object_getClass(a.B_field.C_field.D_field.E_field) == NSClassFromString(@"E"));
            TEST(a.B_field.C_field.D_field.E_field.d_observationInfo == NULL);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.F_field.class == NSClassFromString(@"F") && object_getClass(a.B_field.C_field.D_field.E_field.F_field) == NSClassFromString(@"F"));
            TEST(a.B_field.C_field.D_field.E_field.F_field.d_observationInfo == NULL);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.class == NSClassFromString(@"B") && object_getClass(a.B_field.C_field.D_field.E_field.F_field.B_field) == NSClassFromString(@"B"));
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.d_observationInfo == NULL);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.class == NSClassFromString(@"C") && object_getClass(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field) == NSClassFromString(@"C"));
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.d_observationInfo == NULL);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.class == NSClassFromString(@"D") && object_getClass(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field) == NSClassFromString(@"D"));
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.d_observationInfo == NULL);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.class == NSClassFromString(@"E") && object_getClass(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field) == NSClassFromString(@"E"));
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.d_observationInfo == NULL);
        }
        {
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.class == NSClassFromString(@"F") && object_getClass(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field) == NSClassFromString(@"F"));
            TEST(a.B_field.C_field.D_field.E_field.F_field.B_field.C_field.D_field.E_field.F_field.d_observationInfo == NULL);
        }
    }
    
#if AFFECTING_KEY_PATH_TEST_ON
    {
        //====依赖keyPath && 监听传递==
        a = NextRandomA_1;
        a.B_field = B.random;
        a.C_field = C.random;
        a.D_field = D.random;
        a.E_field = E.random;
        a.F_field = F.random;
        //B_field --依赖--> E_field
        //B_field --依赖--> E_field
        //B_field --依赖--> C_field.char_field
        //C_field --依赖--> D_field.char_field
        //所以对B_field添加监听后：
        //E_field，F_field正常(当然Set方法被替换，但是此处不测这项改变)
        //C_filed的char_field被监听
        //D_field的char_field被监听
        
        [a d_addObserver:obserVerA forKeyPath:@"B_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
        
        {
            TEST(a.class == NSClassFromString(@"A") && object_getClass(a) == NSClassFromString(@"DSKVONotifying_A"));
            id observance = [[(id)a.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"B_field"]);
        }
        
        {
            TEST(a.E_field.class == NSClassFromString(@"E") && object_getClass(a.E_field) == NSClassFromString(@"E"));
        }
        
        {
            TEST(a.F_field.class == NSClassFromString(@"F") && object_getClass(a.F_field) == NSClassFromString(@"F"));
        }
        
        {
            TEST(a.C_field.class == NSClassFromString(@"C") && object_getClass(a.C_field) == NSClassFromString(@"DSKVONotifying_C"));
            id observance = [[(id)a.C_field.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"char_field"]);
        }
        
        {
            TEST(a.D_field.class == NSClassFromString(@"D") && object_getClass(a.D_field) == NSClassFromString(@"DSKVONotifying_D"));
            id observance = [[(id)a.D_field.d_observationInfo valueForKeyPath:@"observances"] firstObject];
            TEST([[observance valueForKeyPath:@"property.keyPath"] isEqualToString:@"char_field"]);
        }
        
        //移除监听， 依赖项复原
        [a d_removeObserver:obserVerA forKeyPath:@"B_field" context:CONTEXT_1];
        
        {
            TEST(a.class == NSClassFromString(@"A") && object_getClass(a) == NSClassFromString(@"A"));
            TEST(a.d_observationInfo == NULL);
        }
        
        {
            TEST(a.E_field.class == NSClassFromString(@"E") && object_getClass(a.E_field) == NSClassFromString(@"E"));
        }
        
        {
            TEST(a.F_field.class == NSClassFromString(@"F") && object_getClass(a.F_field) == NSClassFromString(@"F"));
        }
        
        {
            TEST(a.C_field.class == NSClassFromString(@"C") && object_getClass(a.C_field) == NSClassFromString(@"C"));
            TEST(a.C_field.d_observationInfo == NULL);
        }
        
        {
            TEST(a.D_field.class == NSClassFromString(@"D") && object_getClass(a.D_field) == NSClassFromString(@"D"));
            TEST(a.D_field.d_observationInfo == NULL);
        }
    }
#endif
    
    {
        //====监听不支持的keyPath==
        {
            a = NextRandomA_1;
            a.NSArray_field = @[];
            
            NSException *e = nil;
            
            //不存在的keyPath
            @try {
                [a d_addObserver:obserVerA forKeyPath:@"what.is.this" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            } @catch (NSException *exception) {
                e = exception;
            } @finally {
                TEST(e != nil);
            }
            
            e = nil;
            
            //妄图如此方便地监听数组里每个对象的字段改变是无法实现的
            @try {
                [a d_addObserver:obserVerA forKeyPath:@"NSArray_field.int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            } @catch (NSException *exception) {
                e = exception;
            } @finally {
                TEST(e != nil);
            }
            //系统方法也一样不支持
            @try {
                [a addObserver:obserVerA forKeyPath:@"NSArray_field.int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            } @catch (NSException *exception) {
                e = exception;
            } @finally {
                TEST(e != nil);
            }
            
            //这个keyPath在KVC里是支持的，获取NSArray_field里所有对象的int_field字段平均值，但是想要在KVO里这样监听平均值是无法实现的
            @try {
                [a d_addObserver:obserVerA forKeyPath:@"NSArray_field.@avg.int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            } @catch (NSException *exception) {
                e = exception;
            } @finally {
                TEST(e != nil);
            }
            
            @try {
                [a addObserver:obserVerA forKeyPath:@"NSArray_field.@avg.int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            } @catch (NSException *exception) {
                e = exception;
            } @finally {
                TEST(e != nil);
            }
        }
    }
    
    {
        //====重复添加监听==
        
        {
            a = NextRandomA_1;
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            TEST(a.d_observationInfo != NULL);
            TEST(a.class == NSClassFromString(@"A") && object_getClass(a) == NSClassFromString(@"DSKVONotifying_A"));
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            TEST(a.d_observationInfo == NULL);
            TEST(a.class == NSClassFromString(@"A") && object_getClass(a) == NSClassFromString(@"A"));
        }
        
        {
            a = NextRandomA_1;
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            [a d_addObserver:obserVerB forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            [a d_addObserver:obserVerC forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            [a d_addObserver:obserVerD forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            [a d_removeObserver:obserVerB forKeyPath:@"int_field" context:CONTEXT_1];
            [a d_removeObserver:obserVerC forKeyPath:@"int_field" context:CONTEXT_1];
            TEST(a.d_observationInfo != NULL);
            TEST(a.class == NSClassFromString(@"A") && object_getClass(a) == NSClassFromString(@"DSKVONotifying_A"));
            [a d_removeObserver:obserVerD forKeyPath:@"int_field" context:CONTEXT_1];
            TEST(a.d_observationInfo == NULL);
            TEST(a.class == NSClassFromString(@"A") && object_getClass(a) == NSClassFromString(@"A"));
        }
        
    }
    
    {
        //====移除指定监听==
        [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
        [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_2];
        [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_3];
        [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_4];
        
        [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
        //CONTEXT_1对应的监听者已被移除
        NSArray * observances = [(id)a.d_observationInfo d_valueForKeyPath:@"observances"];
        BOOL notFind_CONTEXT_1 = YES;
        for (DSKeyValueObservance *observance in observances) {
            if (observance.context == CONTEXT_1) {
                notFind_CONTEXT_1 = NO;
                break;
            }
        }
        TEST(observances.count == 3 && notFind_CONTEXT_1);
        
        //不指定context, 移除最后添加的监听
        [a d_removeObserver:obserVerA forKeyPath:@"int_field"];
        observances = [(id)a.d_observationInfo valueForKeyPath:@"observances"];
        BOOL notFind_CONTEXT_4 = YES;
        for (DSKeyValueObservance * observance in observances) {
            if (observance.context == CONTEXT_4) {
                notFind_CONTEXT_4 = NO;
                break;
            }
        }
        TEST(observances.count == 2 && notFind_CONTEXT_4);
        
        [a d_removeObserver:obserVerA forKeyPath:@"int_field"];
        observances = [(id)a.d_observationInfo valueForKeyPath:@"observances"];
        BOOL notFind_CONTEXT_3 = YES;
        for (DSKeyValueObservance * observance in observances) {
            if (observance.context == CONTEXT_3) {
                notFind_CONTEXT_4 = NO;
                break;
            }
        }
        TEST(observances.count == 1 && notFind_CONTEXT_3);
        
        [a d_removeObserver:obserVerA forKeyPath:@"int_field"];
        TEST(a.d_observationInfo == NULL);
    }
    
    {
        //====移除不存在的监听==
        {
            a = NextRandomA_1;
            NSException *e = nil;
            @try {
                [a removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            } @catch (NSException *exception) {
                e = exception;
            } @finally {
                TEST(e != nil);
            }
        }
        
        //移除次数大于监听次数
        {
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            [a d_addObserver:obserVerA forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            
            NSException *e = nil;
            @try {
                [a d_removeObserver:obserVerA forKeyPath:@"int_field" context:CONTEXT_1];
            } @catch (NSException *exception) {
                e = exception;
            } @finally {
                TEST(e != nil);
            }
        }
        
    }
    
    {
        //====监听者提前释放 OR 被监听者提前释放==
        {
            ObserverA *ob = [ObserverA new];
            A *obed = [A random];
            [obed d_addObserver:ob forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            
            NSException *e = nil;
            @try {
                [obed release];
            } @catch (NSException *exception) {
                e = exception;
            } @finally {
                TEST(e != nil);
            }
            
            
            ob = [ObserverA new];
            obed = [A random];
            [obed d_addObserver:ob forKeyPath:@"int_field" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
            //监听者ob提前释放，可以正常将监听者ob remove，但是是极度危险的
            [ob release];
            //因为内部比较的恰好只是是指针值，所以可以正常移出，但是一个指针已被释放，就不应该用做任何用途
            [obed d_removeObserver:ob forKeyPath:@"int_field" context:CONTEXT_1];
        }
        
    }
    
    {
        //====不能对集合对象的属性增加监听==
        NSArray *array = @[@1,@2,@3];
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:@[@1,@2,@3]];
        NSSet *set = [NSSet setWithArray:@[@1,@2,@3]];
        
        NSException *e = nil;
        @try {
            [array d_addObserver:obserVerA forKeyPath:@"count" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
        } @catch (NSException *exception) {
            e = exception;
        } @finally {
            TEST(e != nil);
        }
        
        e = nil;
        
        @try {
            [orderedSet d_addObserver:obserVerA forKeyPath:@"count" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
        } @catch (NSException *exception) {
            e = exception;
        } @finally {
            TEST(e != nil);
        }
        
        e = nil;
        
        @try {
            [set d_addObserver:obserVerA forKeyPath:@"count" options:NSKeyValueObservingOptionNew context:CONTEXT_1];
        } @catch (NSException *exception) {
            e = exception;
        } @finally {
            TEST(e != nil);
        }
        
    }
#endif
}
