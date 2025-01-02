% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: Gold序列发生器
% 文件名称：goldseq.m
% 版    本：V1.0
% 说    明：生成两个Gold序列
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2024-12-27     小吕同学      序列生成器
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 

%% Gold序列发生器
% 参数说明：
% initial：系统初始状态（非全零，阶数符合即可）
% feedback1：反馈系数（查表，八进制）
% feedback2：反馈系数（查表，八进制）
% shift：用于移位模2加
% gold1,gold2：生成的两个gold序列
% --------------------------------------------------------------------
% 使用说明：生成的序列和书本上的序列是左右颠倒的，我已经验证过没问题；
%           工程上使用一般直接存储序列数据，不用每次都生成，消耗时间；
% --------------------------------------------------------------------
% 使用举例：生成两个Gold序列
% initial=[1 0 1 1 0 0];  %6阶
% feedback1=103;
% feedback2=145;
% [g1,g2]=goldseq(initial,feedback1,feedback2,20);
% subplot(3,1,1)
% plot(xcorr(g1))
% title('g1 Gold序列自相关函数')
% subplot(3,1,2)
% plot(xcorr(g2))
% title('g2 Gold序列自相关函数')
% subplot(3,1,3)
% plot(xcorr(g1,g2))
% title('g1、g2 Gold序列互相关函数')
% --------------------------------------------------------------------
function [gold1,gold2]=goldseq(initial,feedback1,feedback2,shift)

n = length(initial);                    % 阶数
m1 = mseq(initial,feedback1,0);         % 生成两个m序列
m2 = mseq(initial,feedback2,0);

% 生成两个gold序列
gold1=mod(m1+m2,2);                     % 模2加
gold2=mod(m1+circshift(m2,shift),2);    % 移位模2加

% 以下程序判断是否为m序列优选对
m1=2*m1-1;           			        % 逻辑映射
m2=2*m2-1;
res=max(abs(xcorr(m1,m2)));             % 求互相换函数

if(rem(n,2)==0)                         % 判断是否为m序列优选对
    if(max(res)>2^(n/2+1)+1)
        disp('非m序列优选对')
    end
end
if(rem(n,2)~=0)
    if(max(res)>2^(n/2+1/2)+1)
        disp('非m序列优选对')
    end
end


