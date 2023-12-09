open System.IO
let lines = seq { yield! System.IO.File.ReadLines "test_case.txt" }

let toIntArray (x: array<string>) = 
    x 
    |> Seq.map System.Int32.Parse
    |> Seq.toArray

let toDiffArray(x) =
    x |> Array.pairwise |> Array.map(fun (x,y) -> y - x)

let isZero x = x = 0
let allZero = 
    function 
    | arr when arr |> Array.forall isZero  -> true
    | _ -> false


let rec recurseUntilDiffZero(diffs) =
    if allZero diffs then [diffs]
    else diffs :: recurseUntilDiffZero (toDiffArray diffs)


let intLines = 
    lines  
    |> Seq.map (fun x -> x.Split(" ")) 
    |> Seq.map (fun x -> toIntArray x)


let diffLines = 
    intLines 
    |> Seq.map(fun x -> recurseUntilDiffZero x)

let part1 = 
    diffLines
    |> Seq.map (fun x -> 
     x |> List.map (fun y ->  Array.last y)
    )
    |> Seq.map (fun x -> List.sum x)
    |> Seq.sum

let part2 = 
    diffLines
    |> Seq.map (fun x -> 
     x |> List.map (fun y ->  Array.head y)
    )
    |> Seq.map (fun x -> List.sum x)
    |> Seq.sum
(*
diffLines |> Seq.iter (fun x -> 
    printf "\n"
    x |> List.iter ( fun y ->
        printf "\n"
        y |> Array.iter (fun z -> 
            printf "%d " z)
     )
)
*)
printf "part1: %d\n" part1
printf "part1: %d\n" part2