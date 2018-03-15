#--------------------------------------------------------------------
# Spacetime Discretization methods in Julia
# Soham 03-2018
#--------------------------------------------------------------------

function setcolormap(vec::Array{Float64,1}, map::String, samples::Int)
    nvec = (vec .- minimum(vec))./(maximum(vec) .- minimum(vec))
    clrs = colormap(map, samples+1)
    return clrs[round.(Int, (nvec*samples)+1)]
end

function drawpatch(patch::Array{Float64,2})
    (Nx, Ny) = size(patch) .- 1
    (wx, wy) = (chebweights(Nx), chebweights(Ny))
    (lx, ly) = (sort(2.0 - cumsum(wx))*200, sort(2.0 - cumsum(wy))*200)
    cmap     = reshape(setcolormap(vec(patch), "Blues", 100000), size(patch))
    canvas   = Drawing(800, 800, "luxor-patch.pdf")
    push!(lx, 400.0)
    push!(ly, 400.0)
    
    #-----------------------------------------------
    # draw patch
    #-----------------------------------------------
    origin(400, 650)
    rotate(-3pi/4)
    setline(0.4)
    for i in 1:Nx+1, j in 1:Ny+1
       sethue((cmap[i,j].r, cmap[i,j].g, cmap[i,j].b))
       rect(lx[i], ly[j], lx[i+1] - lx[i], ly[j+1] - ly[j], :fill)
    end

    #-----------------------------------------------
    # set ticks
    #-----------------------------------------------
    sethue("black")
    setline(0.4)
    (lx0, ly0) = (lx[1], ly[1])
    (lxe, lye) = (lx[end], ly[end])
    (lxm, lym) = (lx0, ly0)./2 .+ (lxe, lye)./2

    # corners
    line(Point(lx0, ly0), Point(lx0, ly0-10), :stroke)
    line(Point(lx0, ly0), Point(lx0-10, ly0), :stroke)
    line(Point(lxe, lye), Point(lxe, lye+10), :stroke)
    line(Point(lxe, lye), Point(lxe+10, lye), :stroke)
    line(Point(lxe, ly0), Point(lxe, ly0-10), :stroke)
    line(Point(lxe, ly0), Point(lxe+10, ly0), :stroke)
    line(Point(lx0, lye), Point(lx0-10, lye), :stroke)
    line(Point(lx0, lye), Point(lx0, lye+10), :stroke)
    line(Point(lx0, ly0), Point(lx0, ly0-10), :stroke)
    line(Point(lx0, ly0), Point(lx0-10, ly0), :stroke)

    # mid points
    line(Point(lxm, ly0), Point(lxm, ly0-10), :stroke)
    line(Point(lx0, lym), Point(lx0-10, lym), :stroke)
    line(Point(lxm, lye), Point(lxm, lye+10), :stroke)
    line(Point(lxe, lym), Point(lxe+10, lym), :stroke)

    # edges
    line(Point(lx0, ly0), Point(lx0, lye), :stroke)
    line(Point(lx0, ly0), Point(lxe, ly0), :stroke)
    line(Point(lxe, ly0), Point(lxe, lye), :stroke)
    line(Point(lx0, lye), Point(lxe, lye), :stroke)

    #-----------------------------------------------
    # tick labels
    #-----------------------------------------------
    settext("(1, 1)", Point(lx0 - 18, ly0 - 18);
            halign = "center",
            valign = "top")
    settext("(-1, -1)", Point(lxe + 18, lye + 18);
            halign = "center",
            valign = "bottom")
    settext("(-1, 1)", Point(lx0 - 20, lye + 20);
            halign = "center",
            valign = "center")
    settext("(1, -1)", Point(lxe + 20, ly0 - 20);
            halign = "center",
            valign = "center")

    #-----------------------------------------------
    # colorbar
    #-----------------------------------------------
    rotate(3pi/4)
    x   = collect(linspace(-200, 200, 100))
    clr = colormap("Blues", 100)

    for i in 1:99
        sethue((clr[i].r, clr[i].g, clr[i].b))
        rect(x[i], 92.5, x[i+1] - x[i], 15, :fill)
    end

    #-----------------------------------------------
    # colobar ticks
    #-----------------------------------------------
    sethue("black")
    setline(0.4)
    line(Point(-200, 107.5), Point(-200, 85), :stroke)
    line(Point(0, 107.5), Point(0, 85), :stroke)
    line(Point(200, 107.5), Point(200, 85), :stroke)
    
    min = findmin(patch)[1] 
    max = findmax(patch)[1]
    med = (min + max)/2

    settext("$min", Point(-200, 80);
                halign = "center",
                valign = "center")
    settext("$med", Point(0, 80);
                halign = "center",
                valign = "center")
    settext("$max", Point(200, 80);
                halign = "center",
                valign = "center")

    #-----------------------------------------------
    #arrow
    #-----------------------------------------------
    sethue("black")
    setline(0.4)
    origin(700, 100)
    arrow(O, O .+ Point(40, -40))
    settext("u", O .+ Point(40, -40);
                halign = "top",
                valign = "right")
    rotate(-pi/2)
    arrow(O, O .+ Point(40, -40))
    settext("v", O .+ Point(40, -40);
                halign = "bottom",
                valign = "right")

    finish()
    return canvas
end

function drawgrid(dbase::Dict{Array{Int,1}, Patch})
    M        = round(Int, sqrt(length(dbase)))
    (Nx, Ny) = size(dbase[[1,1]].value) .- 1
    (wx, wy) = (chebweights(Nx)/M, chebweights(Ny)/M)
    grid     = dict2array(dbase)
   
    colormap = reshape(setcolormap(vec(grid), "Blues", 100000), size(grid))
    canvas   = Drawing(800, 800, "luxor-patch.pdf")   
    origin(400, 650)
    rotate(-3pi/4)
    setline(0.4)

    for m in 1:M, n in 1:M
        (lx, ly) = (sort(2.0 - cumsum(wx))*(200/M), sort(2.0 - cumsum(wy))*(200/M))
        push!(lx, 400.0/M)
        push!(ly, 400.0/M)
        
        # XXX: Shift the coordinates appropriately.
        lx = lx + (m-1)*(200/M)
        ly = ly + (n-1)*(200/M)
            
        cmap = colormap[1+(m-1)*(Nx+1):m*(Nx+1), 1+(n-1)*(Ny+1):n*(Ny+1)]
        #-----------------------------------------------
        # draw patch
        #-----------------------------------------------
        for i in 1:Nx+1, j in 1:Ny+1
            sethue((cmap[i,j].r, cmap[i,j].g, cmap[i,j].b))
            rect(lx[i], ly[j], lx[i+1] - lx[i], ly[j+1] - ly[j], :fill)
        end
    end
    finish()
    return canvas
end

function drawarray(patch::Array{Float64,2})
    M = size(patch)[1]
    (wx, wy) = (repeat([2/M], inner = M), repeat([2/M], inner = M))
    (lx, ly) = (sort(2.0 - cumsum(wx))*200, sort(2.0 - cumsum(wy))*200)
    cmap     = reshape(setcolormap(vec(patch), "Blues", 100000), size(patch))
    canvas   = Drawing(800, 800, "luxor-array.pdf")

    #-----------------------------------------------
    # draw patch
    #-----------------------------------------------
    origin(400, 650)
    rotate(-3pi/4)
    setline(0.4)
    for i in 1:M-1, j in 1:M-1
       sethue((cmap[i,j].r, cmap[i,j].g, cmap[i,j].b))
       rect(lx[i], ly[j], lx[i+1] - lx[i], ly[j+1] - ly[j], :fill)
    end

    #-----------------------------------------------
    # set ticks
    #-----------------------------------------------
    sethue("black")
    setline(0.4)
    (lx0, ly0) = (lx[1], ly[1])
    (lxe, lye) = (lx[end], ly[end])
    (lxm, lym) = (lx0, ly0)./2 .+ (lxe, lye)./2

    # corners
    line(Point(lx0, ly0), Point(lx0, ly0-10), :stroke)
    line(Point(lx0, ly0), Point(lx0-10, ly0), :stroke)
    line(Point(lxe, lye), Point(lxe, lye+10), :stroke)
    line(Point(lxe, lye), Point(lxe+10, lye), :stroke)
    line(Point(lxe, ly0), Point(lxe, ly0-10), :stroke)
    line(Point(lxe, ly0), Point(lxe+10, ly0), :stroke)
    line(Point(lx0, lye), Point(lx0-10, lye), :stroke)
    line(Point(lx0, lye), Point(lx0, lye+10), :stroke)
    line(Point(lx0, ly0), Point(lx0, ly0-10), :stroke)
    line(Point(lx0, ly0), Point(lx0-10, ly0), :stroke)

    # mid points
    line(Point(lxm, ly0), Point(lxm, ly0-10), :stroke)
    line(Point(lx0, lym), Point(lx0-10, lym), :stroke)
    line(Point(lxm, lye), Point(lxm, lye+10), :stroke)
    line(Point(lxe, lym), Point(lxe+10, lym), :stroke)

    # edges
    line(Point(lx0, ly0), Point(lx0, lye), :stroke)
    line(Point(lx0, ly0), Point(lxe, ly0), :stroke)
    line(Point(lxe, ly0), Point(lxe, lye), :stroke)
    line(Point(lx0, lye), Point(lxe, lye), :stroke)

    #-----------------------------------------------
    # tick labels
    #-----------------------------------------------
    settext("(1, 1)", Point(lx0 - 18, ly0 - 18);
            halign = "center",
            valign = "top")
    settext("(-1, -1)", Point(lxe + 18, lye + 18);
            halign = "center",
            valign = "bottom")
    settext("(-1, 1)", Point(lx0 - 20, lye + 20);
            halign = "center",
            valign = "center")
    settext("(1, -1)", Point(lxe + 20, ly0 - 20);
            halign = "center",
            valign = "center")

    #-----------------------------------------------
    # colorbar
    #-----------------------------------------------
    rotate(3pi/4)
    x   = collect(linspace(-200, 200, 100))
    clr = colormap("Blues", 100)

    for i in 1:99
        sethue((clr[i].r, clr[i].g, clr[i].b))
        rect(x[i], 92.5, x[i+1] - x[i], 15, :fill)
    end

    #-----------------------------------------------
    # colobar ticks
    #-----------------------------------------------
    sethue("black")
    setline(0.4)
    line(Point(-200, 107.5), Point(-200, 85), :stroke)
    line(Point(0, 107.5), Point(0, 85), :stroke)
    line(Point(200, 107.5), Point(200, 85), :stroke)
    min = findmin(patch)[1]
    max = findmax(patch)[1]
    med = (min + max)/2

    settext("$min", Point(-200, 80);
                halign = "center",
                valign = "center")
    settext("$med", Point(0, 80);
                halign = "center",
                valign = "center")
    settext("$max", Point(200, 80);
                halign = "center",
                valign = "center")

    #-----------------------------------------------
    #arrow
    #-----------------------------------------------
    sethue("black")
    setline(0.4)
    origin(700, 100)
    arrow(O, O .+ Point(40, -40))
    settext("u", O .+ Point(40, -40);
                halign = "top",
                valign = "right")
    rotate(-pi/2)
    arrow(O, O .+ Point(40, -40))
    settext("v", O .+ Point(40, -40);
                halign = "bottom",
                valign = "right")

    finish()
    return canvas
end
