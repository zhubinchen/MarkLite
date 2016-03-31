# SlideSegment


SlideSegment for iOS,it is composed of ScrollPageView and SegmentView.You can also use either of the two class as an independent

<img src="screenshot.gif" width="270" height="450"/>

Usage
----
```
        //实例化3个view
    UIView *v1 = [[UIView alloc]initWithFrame:CGRectZero];
    v1.backgroundColor = [UIColor purpleColor];
    
    UIView *v2 = [[UIView alloc]initWithFrame:CGRectZero];
    v2.backgroundColor = [UIColor lightGrayColor];
    
    UIView *v3 = [[UIView alloc]initWithFrame:CGRectZero];
    v3.backgroundColor = [UIColor orangeColor];
    
    //需要放上来的view，请务必在ScrollPageView被加载之后给pages属性赋值，否则你需要自己计算每个view的frame
    _pageView.pages = @[v1,v2,v3];
    
    //关联的segment
    _pageView.segment = _pageSegment;
    
    //segment上view对应的标题
    _pageSegment.titles = @[@"标题1",@"标题2",@"标题3"];
    
    //设置选中栏的高亮颜色
    _pageSegment.highlightColor = [UIColor blueColor];
    
    //segment切换时候的回调
    _pageSegment.segmentChanged = ^(NSInteger index){
        _pageView.currentPage = index;
    };
```
        
Contact
----------
* Email:zbc@zhubch.com


License
----------

    Copyright 2015 zhubch, Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    sss
    s
    
    
    ss

        

        
