% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: m/M序列发生器
% 文件名称：mseq.m
% 版    本：V1.0
% 说    明：生成m/M序列
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2024-12-27     小吕同学      序列生成器
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 

%% m/M序列发生器
% 参数说明：
% initial：系统初始状态（非全零，阶数符合即可）
% feedback：反馈系数（查表，八进制）
% mode：为0时生成m序列，长度2^r-1；
%       为1时生成M序列，长度2^r；
% m：生成的m/M二值序列，没有进行逻辑映射；
% --------------------------------------------------------------------
% 使用说明：生成的序列和书本上的序列是左右颠倒的，我已经验证过没问题；
%           工程上使用一般直接存储序列数据，不用每次都生成，消耗时间；
% --------------------------------------------------------------------
% 使用举例：生成一个m序列
% initial=[1 0 1 1 0 0];  % 6阶
% feedback=103;
% m = mseq(initial,feedback,0);
% m = 2*m-1;
% subplot(2,1,1)
% plot(m)
% subplot(2,1,2)
% plot(xcorr(m))
% --------------------------------------------------------------------
% 使用举例：生成一个M序列
% 仅改动一句
% m = mseq(initial,feedback,1);
% --------------------------------------------------------------------
function [m]=mseq(initial,feedback,mode)

n=length(initial);				% 阶数
temp=de2bi(oct2dec(feedback));  % 反馈系数8转10进制转2进制
temp=fliplr(temp);			    % 翻转
final=temp(2:length(temp));     % 舍去首位

output=[];
comp=[zeros(1,n-1) 1];          % 生成M序列时使用
for ii=1:2^n-1
    output=[output initial(n)];
    if(mode & initial==comp)    % 生成M序列时使用
        output=[output 0];
    end
    temp=mod(sum(final.*initial),2);
    initial=[temp initial(1:n-1)];
end

m=output;                       % 没有进行逻辑映射
