% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: 双极性M元循环移位键控扩频
% 文件名称：MarySS_CSK_BPSK.m
% 版    本：V1.0
% 说    明：双极性M元循环移位键控扩频的扩频解扩过程实现
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2025-1-2         Lv.          发布
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 

%% 双极性循环移位键控扩频(Bipolar M-ary Cyclic Shift Keyed Spread Spectrum,BMCSKSS)
close all; clear; clc;

%% 消息生成
bits=120;                           % 消息个数
mes=randi([0,1],1,bits);
mary=5;                             % mary进制信源
p=rem(length(mes),mary);            % bit补齐
if(p~=0)
    mes=[mes zeros(1,mary-p)];
end
rmes=reshape(mes,mary,[])';         % 串并转换
bimes=bi2de(rmes);                  % 8进制，3比特

%% 4元Gold序列4相CSK序列生成
initial=[1 0 1 1 0 0];              % 6阶
feedback1=103;
feedback2=147;
m1 = mseq(initial,feedback1,0);
m2 = mseq(initial,feedback2,0);
L=length(m2);                       % 扩频码长

gold=[];                            % 4元扩频
gold(1,:) = 2*(mod(m1+m2,2)) - 1;
gold(2,:) = 2*(mod(m1+circshift(m2,15),2)) - 1;
gold(3,:) = 2*(mod(m1+circshift(m2,30),2)) - 1;
gold(4,:) = 2*(mod(m1+circshift(m2,45),2)) - 1;

n=[24 8 -8 -24];                    % 4相循环移位
for i=1:length(n)
    goldcsk1(i,:)=circshift(gold(1,:),n(i));
    goldcsk2(i,:)=circshift(gold(2,:),n(i));
    goldcsk3(i,:)=circshift(gold(3,:),n(i));
    goldcsk4(i,:)=circshift(gold(4,:),n(i));
end

for i=1:length(n)                   % BPSK
    goldcsk1(i+4,:)=-goldcsk1(i,:);
    goldcsk2(i+4,:)=-goldcsk2(i,:);
    goldcsk3(i+4,:)=-goldcsk3(i,:);
    goldcsk4(i+4,:)=-goldcsk4(i,:);
end

gold4csk=[goldcsk1;goldcsk2;goldcsk3;goldcsk4];

% % 扩频解码
% en1=[];
% en2=[];
% en3=[];
% en4=[];
% for i=1:4
%     en1(i,:)=xcorr(goldcsk1(i,:),gold(1,:));
%     en2(i,:)=xcorr(goldcsk2(i,:),gold(2,:));
%     en3(i,:)=xcorr(goldcsk3(i,:),gold(3,:));
%     en4(i,:)=xcorr(goldcsk4(i,:),gold(4,:));
% 
%     en1(i+4,:)=xcorr(goldcsk1(i+4,:),gold(1,:));
%     en2(i+4,:)=xcorr(goldcsk2(i+4,:),gold(2,:));
%     en3(i+4,:)=xcorr(goldcsk3(i+4,:),gold(3,:));
%     en4(i+4,:)=xcorr(goldcsk4(i+4,:),gold(4,:));
% end
% cgold4csk=[en1;en2;en3;en4];
% 
% figure
% hold on
% for i=1:8
%     subplot(8,1,i)
%     plot(cgold4csk(i,:));
% end
% clear initial feedback1 feedback2 m1 m2 goldcsk1 goldcsk2 goldcsk3 goldcsk4 n i

%% 选择扩频码
ssmes=zeros(length(bimes),length(gold(1,:)));
for i=1:length(bimes)
    ssmes(i,:)=gold4csk(bimes(i,1)+1,:);
end
ssmes=ssmes';
ssmes=reshape(ssmes,1,[]);

%% 脉冲成型、上变频、信道、下变频、低通滤波

%% 相关解码
N=length(ssmes)/L;                  % 消息个数
en=zeros(1,N);                      % 存储解码
cor=[];                             % 存储互相关函数作图
M=size(gold,1);                     % M元扩频码个数

for i=1:N
    buf=ssmes(1,1+(i-1)*L:i*L);     % 选取窗口
    corbuf=zeros(M,2*L-1);          % 自相关矩阵缓存
    for j=1:M                       % 跟原始扩频码做互相关(注意顺序)
        corbuf(j,:)=xcorr(gold(j,:),buf);
    end
    cor=[cor corbuf];               % 存储相关矩阵
end

xxx=[];                             % 存储互相关函数峰值的位置和峰值
for i=1:N
    buf=cor(1:4,1+(i-1)*125:i*125);                 % 选取窗口
    if(max(buf(:))<abs(min(buf(:))))                % 判断极性，如果负极性找负峰值
        [max_val, linear_idx] = min(buf(:));
    else                                            % 反之，正极性找正峰值
        [max_val, linear_idx] = max(buf(:));
    end
    [row, col] = ind2sub(size(buf), linear_idx);    % 转成行列形式
    xxx(i,:)=[row,col,max_val];
end

encode=[];
for i=1:N                           % 根据扩频码和互相关峰值位置与极性，解码
    if(xxx(i,2)<47)
        shift=0;
    elseif(xxx(i,2)<63)
        shift=1;
    elseif(xxx(i,2)<79)
        shift=2;
    else
        shift=3;
    end
    if(xxx(i,3)<0)
        sig=4;
    else
        sig=0;
    end
    encode(i,1)=(xxx(i,1)-1)*8+sig+shift;
end
encode=encode';
ec=de2bi(encode)';
dec=reshape(ec,1,[]);

%% 误码率
A=find(dec~=mes);
BER=length(A)/length(mes);
disp(['解码误码率：' num2str(BER)])

%% 画图
figure
hold on
for i=1:M
    subplot(4,1,i)
    plot(cor(i,:));
    title(['接收消息与第' num2str(i) '个扩频码互相关结果'])
    axis([1 length(cor) -L L]);
end

figure
hold on
for i=1:M
    plot(cor(i,:));
    title('互相关四合一图')
end
