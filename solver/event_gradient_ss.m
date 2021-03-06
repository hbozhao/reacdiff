function flag = event_gradient_ss(t,y,yp,k2,thresh,component)
  %y = 1 when the L2 norm of the gradient field is below thresh(1)
  %y = 2 when the 2-norm of the time derivative yp is below thresh(2)
  %note that y is in Fourier space.
  %L2 norm of the gradient field is \int_{|| \nabla y(x) ||^2 dx} = \int_{|| k ||^2 ||y(k)||^2 dk}
  %k2 should correspond to each row of y
  %component (1 by default) is the index of the species
  if nargin < 6
    component = 1;
  end
  flag = false;
  dy = gradient_norm(y,k2,component);
  if (dy<thresh(1))
    flag = 1;
    return;
  end
  n = length(k2);
  normyp = norm(yp((component-1)*n+(1:n)));
  if (normyp<thresh(2))
    flag = 2;
    return;
  end
end
