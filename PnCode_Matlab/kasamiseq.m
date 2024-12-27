% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: 小集合Kasami序列发生器
% 文件名称：Kasamiseq.m
% 版    本：V1.0
% 说    明：生成一个Kasami序列
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2024-12-27     小吕同学      序列生成器
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 

%% 小集合Kasami序列发生器
% 参数说明：
% initial：系统初始状态（非全零，阶数符合即可）
% feedback：反馈系数（查表，八进制）
% shift：用于移位模2加
% kasami：生成的一个Kasami序列
% --------------------------------------------------------------------
% 使用说明：生成的序列和书本上的序列是左右颠倒的，我已经验证过没问题；
%           工程上使用一般直接存储序列数据，不用每次都生成，消耗时间；
% --------------------------------------------------------------------
% 使用举例：生成一个Kasami序列
% initial=[1 0 1 1 0 0];			%6阶
% feedback=103;
% k1 = kasamiseq(initial,feedback,0);
% k1 = 2*k1-1;
% feedback=103;
% k2 = kasamiseq(initial,feedback,1);
% k2 = 2*k2-1;
% subplot(3,1,1)
% plot(xcorr(k1))
% title('k1 Kasami序列自相关函数')
% subplot(3,1,2)
% plot(xcorr(k2))
% title('k2 Kasami序列自相关函数')
% subplot(3,1,3)
% plot(xcorr(k1,k2))
% title('k1、k2 Kasami序列互相关函数')
% --------------------------------------------------------------------
function [kasami]=kasamiseq(initial,feedback,shift)

n=length(initial);				    % 阶数
if(rem(n,2)~=0)
    disp('Kasami序列要求阶数为偶数！')
end

m = mseq(initial,feedback,0);       % 生成m序列
ms=fliplr(m);                       % 翻转
temp1 = 2^(n/2)+1;
temp2 = 2^(n/2)-1;

ka=[];
for i=1:temp2                       % m序列间隔temp1挑选
    ka=[ka ms(1+(i-1)*temp1)];
end

if(shift>temp2)
    disp('移位数大于阶数！')
end
ka=circshift(ka,shift);             % 循环移位

kas=[];
for i=1:temp1                       % 重复temp1次
    kas=[kas ka];
end

kasami=fliplr(mod(ms+kas,2));       % 模2加