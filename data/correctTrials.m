function pts = correctTrials(pts,flex)
% this script corrects the trialdef to ensure that movement prep does not
% trigger from secondary flex/ext
    trlst = [];
    for tr = 1:size(pts,1)
        trX = pts(tr,:);
        if trX(3)>0
          preMov = std(flex(trX(1)-1000:trX(1),trX(3)));
          postMov = std(flex(trX(1):trX(1)+500,trX(3)));
          snr = postMov/preMov;
          plot(flex(trX(1)-1000:trX(1)+500))
          if snr>20
              trlst = [trlst tr];
              title('accept')
          else
              trlst;
              title('reject')
              %reject
          end
        else
              trlst = [trlst tr];            
        end
        
    end
    
    pts = pts(trlst,:);