function A = threshold(A,varargin)

B = oo.help.parse_input(varargin,'data','tf_vol');
thres = B.thres;

for i = 1:numel(A)
    
    data = A(i).(B.data);
    
    thresholded = data < thres;
    
    A(i).thresholded = thresholded;
    
end
end