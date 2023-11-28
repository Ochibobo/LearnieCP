import Base: size
using Parameters
"""
    @with_kw struct Rectangle
        startTime::Int
        duration::Int
        endTime::Int
        height::Int

        function Rectangle(startTime::Int, endTime::Int, height::Int)
            if(startTime >= endTime) throw(ArgumentError("Start Time cannot be greater than or equal to the end time"))
            new(startTime, (endTime - startTime), endTime, height)
        end
    end

`Rectangle` structure used to represent an activity.
"""
@with_kw struct Rectangle
    startTime::Int
    duration::Int
    endTime::Int
    height::Int

    function Rectangle(startTime::Int, endTime::Int, height::Int)
        if(startTime > endTime) 
            throw(ArgumentError("Start Time cannot be greater than or equal to the end time"))
        end
        new(startTime, (endTime - startTime), endTime, height)
    end
end


"""
    @with_kw struct Entry
        key::Int
        value::Int
    end

`Entry` to the profile.
"""
@with_kw struct Entry
    key::Int
    value::Int
end


"""
    @with_kw struct Profile
        profileRectangles::Vector{Rectangle}

        function Profile(rects::Vector{Rectangle})
            new(rects)
        end

        function Profile(rects::Vararg{Rectangle})
            new(collect(rects))
        end
    end

`Profile` structure used to store activities.
"""
@with_kw struct Profile
    profileRectangles::Vector{Rectangle}

    function Profile(rects::Vector{Rectangle})
        ## Get the number of rectangles (activities) passed
        n = length(rects) 
        ## Entries (events) to assist in profile creation
        ## The first n entries hold the (startTime, height), the next n elements hold the (endTime, - height)
        points = Vector{Entry}(undef, 2 * n + 2)
        ## Instance of the profile rectangles
        profileRectangles = Vector{Rectangle}()

        for i in eachindex(rects)
            rect = rects[i]
            ## Get the start time and the height
            points[i] = Entry(rect.startTime, rect.height)
            ## Get the endTime and negate the rectange height
            points[i + n] = Entry(rect.endTime, -rect.height)
        end

        ## The last 2 elements represent the start event and the end event
        points[2 * n + 1] = Entry(typemin(Int), 0)
        points[2 * n + 2] = Entry(typemax(Int), 0)

        ## Sort the entries by the key
        sort!(points, by = entry -> entry.key)

        ## Creating the timeline
        sweepHeight = 0
        sweepTime = points[1].key

        for entry in points
            t = entry.key
            h = entry.value

            if t != sweepTime
                ## Add a new rectangle to the 
                push!(profileRectangles, Rectangle(sweepTime, t, sweepHeight))
                sweepTime = t
            end
            ## Update the sweepHeight
            sweepHeight += h
        end

        new(profileRectangles)
    end

    function Profile(rects::Vararg{Rectangle})
        Profile(collect(rects))
    end
end


"""
    Base.size(p::Profile)

Function to get the `size` of the profile. This returns the number of profile rectangles.
"""
Base.size(p::Profile) = length(p.profileRectangles)


"""
    getRectangle(p::Profile, i::Integer)::Rectangle

Function to retrieve the rectangle at index i
"""
function getRectangle(p::Profile, i::Integer)::Rectangle
    n = size(p)
    if i > n throw(DomainError("No such element.Index $i is greater than the profile size of $n")) end

    return p.profileRectangles[i]
end


"""
    rectangleIndex(p::Profile, t::Int)::Int

Function to retrieve the rectangle index of the profile that overlaps the given time `t`. That is, the rectangle index `i`
of the rectangle whose `startTime <= t && endTime > t`.
"""
function rectangleIndex(p::Profile, t::Int)::Int
    profileRects = p.profileRectangles

    for (i, r) in enumerate(profileRects)
        if r.startTime <= t < r.endTime
            return i
        end
    end

    return -1;
end


"""
    rectangles(p::Profile)::Vector{Rectangle}

Function to return the vector of rectangles belonging to a particular `Profile`
"""
function rectangles(p::Profile)::Vector{Rectangle}
    return p.profileRectangles
end



### Testing the implementation above
# activities = [
#     Rectangle(0, 4, 1), Rectangle(1, 3, 2), Rectangle(3, 5, 1), Rectangle(4, 7, 2)
# ]

# p = Profile(activities)

# println(rectangles(p))


# activities = [
#     Rectangle(1, 10, 3),
#     Rectangle(1, 10, 1),
#     Rectangle(1, 10, 2)
# ]


# function generateRectangle()
#     startTime = rand(1:100)
#     endTime  = startTime + 1 + rand(1:30)
#     height = rand(1:30)

#     return Rectangle(startTime, endTime, height)
# end

# activities = map(_ -> generateRectangle(), 1:10)

# function discrete_profiles(rects)
#     minH = minimum(map(r -> r.startTime, filter(r -> r.height > 0, rects)))
#     maxH = maximum(map(r -> r.endTime, filter(r -> r.height > 0, rects)))

#     heights = zeros(Int, maxH - minH)

#     for r in rects
#         if(r.height > 0)
#             println(r)
#             for i in r.startTime:(r.endTime - 1)
#                 heights[(i - minH) + 1] += r.height
#             end
#         end
#     end

#     println(heights)

#     return heights
# end

# p = Profile(activities)
# rectangles(p)
# discrete_p = discrete_profiles(rectangles(p))
# discrete_r = discrete_profiles(activities)

# all(i -> i == 1, discrete_p .== discrete_r)

# size(p) <= length(activities) * 2 + 2



"""
Compulsory parts are time tables. 

The events sorted are the start & end times of compulsory parts.
Find a way to plot the eventual profile using a histogram
"""