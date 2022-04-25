function [EV,SIGMA] = pdfExpVal(pdf,sup)

EV =  sum(pdf.*sup*diff(sup(2:3)));

%STD
SIGMA = sqrt(sum((pdf.*diff(sup(2:3))).*((sup-EV).^2)));
