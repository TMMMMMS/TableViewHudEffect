# TableViewHudEffect
一种tableView滑动时遮盖头部控件的效果，当tableView在顶部时，头部控件可响应事件

![record.gif](https://upload-images.jianshu.io/upload_images/2172432-3943c2747dd50ab2.gif?imageMogr2/auto-orient/strip)

最近项目中有个页面效果，具体如下
1.类似tableView上添加CustomView，当tableView顶部停留时时，CustomView可以响应事件
2.当tableView滑动时，遮盖住CustomView，同时CustomView不能响应事件
 
初步的设计方案是tableView设置contentInset，CustomView添加到tableView的contentInset处，这样布局存在的问题是CustomView会与tableView一起滑动，不满足需求
 
重新设计的方案是控制器的view上依次添加CustomView、tableView，tableView设置contentInset并将tableView的背景色设为透明，接下来就是对一些UIScrollViewDelegate回调方法的处理
 
在处理一系列回调方法中，有一个拖动手势问题让我纠结了一阵子：慢慢滑动tableView和以一个初速度滑动tableView，下面对两种拖动手势做文字上的简要描述：
 __方式一__ --- 慢慢滑动tableView：是指在手指不离开屏幕的情况下，拖动tableView
__方式二__ --- 以一个初速度滑动tableView：向屏幕上方或屏幕下方以一个初速度滑动屏幕，并且手指离开屏幕
 
因为这两种滑动所走的回调不同，所以需要分别处理
 
如何区分这两种方式的手势，通过__- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate__的decelerate。该回调仅仅处理方式一的手势，可以通过BOOL值__decelerate__去区分，YES为方式二，NO为方式一。

因为回调方法中有些自定义的属性需要配合整个代码去理解，所以这里只放出一部分关联性不强的代码片段
```
// 控制导航栏和HeaderView的灰度显示
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat scale = (offsetY + self.headerViewH) / (self.headerViewH+10);
    if (scale > 0.6) {
        scale = 0.6;
    }
    self.hudView.alpha = scale;
    
}
```
如果你有好的实现思路或者其它可以优化的地方，欢迎来[这里](https://www.jianshu.com/p/89badf1e596e)与我探讨交流
