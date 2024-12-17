use dominion::models::structs::StructCard;
use dominion::models::enums::EnumCardValue;
use dominion::models::traits::EnumCardValueInto;

fn sort(arr: @Array<StructCard>) -> Array<StructCard> {
    // If array is empty or has 1 element, it's already sorted
    if arr.len() <= 1 {
        return arr.clone();
    }

    // Perform merge sort
    return merge_sort(arr, 0, arr.len() - 1);
}

// Helper function to merge two sorted subarrays
fn merge(arr: @Array<StructCard>, left: usize, mid: usize, right: usize) -> Array<StructCard> {
    let mut i = left;
    let mut j = mid + 1;
    let mut result: Array<StructCard> = array![];

    // Copy elements before left index
    let mut k = 0;
    while k < left {
        result.append((*arr[k]).clone());
        k += 1;
    };

    // Merge the two subarrays
    while i <= mid && j <= right {
        let left_value: u32 = (*arr[i].m_value).into();
        let right_value: u32 = (*arr[j].m_value).into();

        if left_value <= right_value {
            result.append((*arr[i]).clone());
            i += 1;
        } else {
            result.append((*arr[j]).clone());
            j += 1;
        }
    };

    // Copy remaining elements from left subarray
    while i <= mid {
        result.append((*arr[i]).clone());
        i += 1;
    };

    // Copy remaining elements from right subarray
    while j <= right {
        result.append((*arr[j]).clone());
        j += 1;
    };

    // Copy remaining elements after right index
    let mut k = right + 1;
    while k < arr.len() {
        result.append((*arr[k]).clone());
        k += 1;
    };

    result
}

// Recursive merge sort implementation
fn merge_sort(arr: @Array<StructCard>, left: usize, right: usize) -> Array<StructCard> {
    if left >= right {
        let mut result = array![];
        let mut i = 0;
        while i < arr.len() {
            result.append((*arr[i]).clone());
            i += 1;
        };
        return result;
    }

    let mid = left + (right - left) / 2;

    // Sort first and second halves
    let sorted_left = merge_sort(arr, left, mid);
    let sorted_right = merge_sort(arr, mid + 1, right);

    // Create new array with sorted elements
    let mut result = array![];
    let mut i = 0;
    while i < sorted_left.len() {
        result.append(sorted_left[i].clone());
        i += 1;
    };
    let mut i = 0;
    while i < sorted_right.len() {
        result.append(sorted_right[i].clone());
        i += 1;
    };

    merge(@result, 0, mid, right)
}
