using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BubbleGen : MonoBehaviour
{

    [SerializeField] private GameObject _prefab;
    private List<GameObject> _list;
    // Start is called before the first frame update
    void Start()
    {
    
        _list = new List<GameObject>();
        _Gen();

    }

    private void _Gen(){
            
        var n = Instantiate( _prefab,transform,false );
        n.gameObject.SetActive(true);

        var p = transform.position;
        var ss = Random.value * 0.5f + 0.5f;
        n.transform.localScale = new Vector3(ss,ss,ss);
        n.transform.localPosition = new Vector3(
            2f*(Random.value - 0.5f),
            2f*(Random.value - 0.5f),
            2f*(Random.value - 0.5f) 
        );
        _list.Add(n);

        if(_list.Count>30){
            Destroy(_list[0]);
            _list.RemoveAt(0);
        }

        Invoke("_Gen",0.2f);

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
