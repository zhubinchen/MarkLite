//
//  CodeViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-31.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "CodeViewController.h"
#import "PreviewViewController.h"
#import "EditView.h"
#import "FileManager.h"
#import "ZBCKeyBoard.h"

@interface CodeViewController () <UITextViewDelegate>

@end

@implementation CodeViewController
{
    UIBarButtonItem *preview;
    PreviewViewController *preViewVc;
    UIPopoverController *popVc;
    FileManager *fm;
    
    float lastOffsetY;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    preview = [[UIBarButtonItem alloc]initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(preview)];

    _editView.delegate = self;
    /*# Code - コードの挿入
     
     ```ruby:qiita.rb
     puts 'The best way to log and share programmers knowledge.'
     ```
     
     puts 'The best way to log and share programmers knowledge.'
     
     また、コードをインライン表示することも可能です。
     
     ` puts 'Qiita'` はプログラマのための技術情報共有サービスです。
     
     # Format Text - テキストの装飾
     ## Headers - 見出し
     
     # これはH1タグです
     ## これはH2タグです
     ###### これはH6タグです
     
     # Emphasis - 強調
     
     *これはイタリック体です*
     
     _これもイタリック体です_
     
     _これは_イタリック体になりません
     
     **これは太字です**
     
     __これも太字です__
     
     # Lists - リスト
     Disc型
     
     * 文頭に「*」「+」「-」のいずれかを入れるとDisc型リストになります
     + 要点をまとめる際に便利です
     - リストを挿入する際は、リストの上下に空行がないと正しく表示されません
     
     Decimal型
     
     1. 文頭に「数字.」を入れるとDecimal型リストになります
     2. 1.2.3.と入れていくといい具合です
     3. リストを挿入する際は、リストの上下に空行がないと正しく表示されません
     
     Blockquotes - 引用
     
     > 文頭に>を置くことで引用になります。
     > 複数行にまたがる場合、改行のたびにこの記号を置く必要があります。
     > 引用の上下にはリストと同じく空行がないと正しく表示されません
     > 引用の中に別のMarkdownを使用することも可能です。
     
     これはネストされた引用です。
     
     # Horizontal rules - 水平線
     
     下記は全て水平線として表示されます
     
     * * *
     ***
     *****
     - - -
     ---------------------------------------
     
     # Links - リンク
     
     [リンクテキスト](URL "タイトル")
     
     タイトル付きのリンクを投稿できます。
     
     
     # Images - 画像埋め込み
     
     ![代替テキスト](画像のURL)
     
     タイトル無しの画像を埋め込む
     
     ![代替テキスト](画像のURL "画像タイトル")
     
     ![Qiita](http://qiita.com/system/icons/1/medium/favicon.png "Qiita")
     
     タイトル有りの画像を埋め込む
     
     # その他
     
     バックスラッシュ[\]をMarkdownの前に挿入することで、Markdownをエスケープ(無効化)することができます。
     
     \# H1
     
     エスケープされています*/

//    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 40, -40, 40, 40)];
//    v.backgroundColor = [UIColor colorWithRGBString:@"eeff00"];
//    [_editView.keyboard addSubview:v];
    
    if (kIsPhone) {
        [self loadFile];
    } else {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadFile) name:@"ChangeFile" object:nil];
    }
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    
    if (kIsPhone) {
        return;
    }
    self.tabBarController.title = title;
    self.tabBarItem.title = @"代码";
}

- (void)viewWillAppear:(BOOL)animated
{
    if (kIsPhone) {
        self.navigationItem.rightBarButtonItem = preview;
    } else {
        self.tabBarController.navigationItem.rightBarButtonItem = preview;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.rightBarButtonItem = nil;
    [self saveFile];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (kIsPhone) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (kIsPhone) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!kIsPhone) {
        return;
    }
    if (scrollView.contentOffset.y < -40) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    if (scrollView.contentOffset.y - lastOffsetY > 100) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } else if (scrollView.contentOffset.y - lastOffsetY < -100) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }

    lastOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    lastOffsetY = 0;
}

- (void)loadFile
{
    NSString *path = [FileManager sharedManager].currentFilePath;

    NSString *htmlStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    NSArray *temp = [path componentsSeparatedByString:@"/"];
    self.title = temp[temp.count - 1];
    
    self.editView.text = htmlStr;
    [self.editView updateSyntax];
}

- (void)preview
{
    if (kIsPhone) {
        [self performSegueWithIdentifier:@"preview" sender:self];
    } else {
        if (popVc == nil) {
            PreviewViewController *vc = [[PreviewViewController alloc]init];
            vc.view.backgroundColor =[UIColor whiteColor];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            popVc.popoverContentSize = CGSizeMake(320,360);
            vc.size = popVc.popoverContentSize;
            popVc = [[UIPopoverController alloc] initWithContentViewController:nav];
        }

        [popVc presentPopoverFromBarButtonItem:self.tabBarController.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void)saveFile
{
    NSString *path = [FileManager sharedManager].currentFilePath;

    NSData *content = [self.editView.text dataUsingEncoding:NSUTF8StringEncoding];
    [content writeToFile:path atomically:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
