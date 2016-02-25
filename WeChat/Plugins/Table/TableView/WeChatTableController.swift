//
//  WeChatTableViewDelegate.swift
//  WeChat
//
//  Created by Smile on 16/1/11.
//  Copyright © 2016年 smile.love.tao@gmail.com. All rights reserved.
//

import UIKit

@objc protocol WeChatPropDelegate {
    optional var CELL_HEIGHT:CGFloat {get set}
    optional var CELL_HEADER_HEIGHT:CGFloat{get set}
    optional var CELL_FOOTER_HEIGHT:CGFloat{get set}
}

protocol WeChatCustomTableViewControllerDelete {
    func leftBarItemClick()
}

//自定义TableViewController,添加左侧边栏
class WeChatCustomTableViewController:UITableViewController,SliderContainerViewControllerDelegate {
    
    let leftBarImageWidthAndHegiht:CGFloat = 40//左侧按钮大小
    var sliderContainerViewController:SliderContainerViewController?
    var delegate:WeChatCustomTableViewControllerDelete?
    
    //MARKS: 创建导航条左右侧图片
    func createBarItem(isLeft:Bool){
        let imageView = UIImageView(image: UIImage(named: "my-header"))
        imageView.frame = CGRectMake(0, 0, leftBarImageWidthAndHegiht, leftBarImageWidthAndHegiht)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
        
        let item = UIBarButtonItem(customView: imageView)
        if isLeft {
            self.navigationItem.leftBarButtonItem = item
            imageView.addGestureRecognizer(WeChatUITapGestureRecognizer(target:self,action: "sliderLeftBarItemClick:"))
        } else {
            self.navigationItem.rightBarButtonItem = item
            imageView.addGestureRecognizer(WeChatUITapGestureRecognizer(target:self,action: "sliderRightBarItemClick:"))
        }
        
        if sliderContainerViewController == nil {
            sliderContainerViewController = ((UIApplication.sharedApplication().delegate) as! AppDelegate).sliderContainerViewController
            sliderContainerViewController?.sliderDelegate = self
        }
    }
    
   
    //MARKS: 左侧头像点击事件
    func sliderLeftBarItemClick(gestrue: WeChatUITapGestureRecognizer){
        sliderContainerViewController!.toggleLeftPanel()
        delegate?.leftBarItemClick()
    }
    
    //MARKS: 右侧头像点击事件
    func sliderRightBarItemClick(gestrue: WeChatUITapGestureRecognizer){
        sliderContainerViewController!.toggleRightPanel()
    }
    
    //MARKS: 添加tableView点击事件
    func addTableViewClick() {
        let tap = WeChatUITapGestureRecognizer(target:self,action: "tableViewClick:")
        self.tableView.addGestureRecognizer(tap)
    }
    
    //MARKS: 显示左侧边栏
    func toggleLeftPanel() {
        if sliderContainerViewController?.xOffset > 0 {
            addTableViewClick()
        } else {
            for ges in self.tableView.gestureRecognizers! {
                self.tableView.removeGestureRecognizer(ges)
            }
        }
    }
    
    //MARKS: 显示右侧边栏
    func toggleRightPanel() {
        if sliderContainerViewController?.xOffset < 0 {
            addTableViewClick()
        } else {
            for ges in self.tableView.gestureRecognizers! {
                self.tableView.removeGestureRecognizer(ges)
            }
        }
    }
    
    //MARKS: tableView点击事件
    func tableViewClick(gestrue: WeChatUITapGestureRecognizer){
        if sliderContainerViewController?.currentView?.frame.origin.x > 0 {
            sliderContainerViewController!.toggleLeftPanel()
        } else {
            sliderContainerViewController!.toggleRightPanel()
        }
    }
    
    //MARKS: 添加或删除手势
    func addOrRemoveRecognizer(needSwipeShowMenu:Bool){
        self.sliderContainerViewController?.needSwipeShowMenu = needSwipeShowMenu
        self.sliderContainerViewController?.setNeedSwipeShowMenu()
    }
}


class WeChatTableViewNormalController:WeChatCustomTableViewController,WeChatPropDelegate {
    
    //MARKS: 重写协议的属性
    var CELL_HEADER_HEIGHT:CGFloat {
        get {
            return 20
        }
        
        set {
            self.CELL_HEADER_HEIGHT = newValue
        }
    }
    
    var CELL_FOOTER_HEIGHT:CGFloat {
        get {
            return 1
        }
        
        set {
            self.CELL_FOOTER_HEIGHT = newValue
        }
    }
    
    //MARKS: 获取随机数
    func getRandom(min:UInt32,max:UInt32) -> UInt32 {
        let min:UInt32 = min
        let max:UInt32 = max
        let num = arc4random_uniform(max - min) + min
        return num
    }
    
    //MARKS: 初始化tableview一些属性
    func initTableView(){
        tableView.scrollEnabled = false
        tableView.backgroundColor = getBackgroundColor()
    }
    
    //MARKS: 设置背景色
    func getBackgroundColor() -> UIColor {
        return UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
    }
    
    //MARKS: 取消tableview cell选中状态
    func setCellStyleNone(x:Int,y:Int,callback:(cell:UITableViewCell) -> ()) -> UITableViewCell{
        var _cell:UITableViewCell = UITableViewCell()
        for(var i = 0;i < tableView.numberOfSections; i++){
            for(var j = 0;j < tableView.numberOfRowsInSection(i);j++){
                let indexPath = NSIndexPath(forRow: j, inSection: i)
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                cell?.selectionStyle = .None
                
                if i == x && j == y {
                    callback(cell: cell!)
                    _cell = cell!
                }
            }
        }
        
        return _cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CELL_HEADER_HEIGHT
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CELL_FOOTER_HEIGHT
    }
}

/*
 * MARKS: 自定义tableViewController,用于去掉底部空白
 */
class WeChatTableFooterBlankController:WeChatTableViewNormalController {
    
    //MARKS: 设置背景色,用于tableviewfooter一致
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //let _section = tableView.headerViewForSection(section)
        let view = UIView()
        view.backgroundColor = getBackgroundColor()
        return view
    }
    
    //MARKS: 去掉tableview底部空白
    func createFooterForTableView(){
        let view = UIView()
        view.backgroundColor = getBackgroundColor()
        tableView.tableFooterView = view
    }
}